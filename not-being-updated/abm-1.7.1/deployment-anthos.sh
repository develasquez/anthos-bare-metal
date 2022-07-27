#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script must be executed from the Anthos Workstation
echo "This script must be executed from the Cloud Shell" 
source ./variables.env
set -eu

# Copy variables.env to /root/ directory
# echo ""
# echo "Copying script into $ABM_WS"
# gcloud beta compute scp variables.env root@$ABM_WS:~ --zone "$ZONE" --tunnel-through-iap --project "$PROJECT_ID"

# SSH into the VM as root
echo ""
echo "Logging as root into $ABM_WS"
gcloud beta compute ssh --zone "$ZONE" "root@$ABM_WS"  --tunnel-through-iap --project "$PROJECT_ID" << EOF

source ./variables.env

# Installing BMCTL, KUBECTL & DOCKER
echo ""
echo "Installing bmctl, kubectl and generating keys for service account"

# Create ABM Keys for Service Account
echo ""
echo "Generating keys for the Service Account"
gcloud iam service-accounts keys create bm-gcr.json \
--iam-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com

# Download bmctl & kubectl
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl and bmctl into /usr/local/sbin/
echo ""
echo "Installing kubectl"
chmod +x kubectl
mv kubectl /usr/local/sbin/

echo ""
echo "Installing bmctl"
mkdir baremetal && cd baremetal
gsutil cp gs://anthos-baremetal-release/bmctl/1.7.1/linux-amd64/bmctl .
chmod a+x bmctl
mv bmctl /usr/local/sbin/

# Installing Docker
cd ~
echo ""
echo "Installing docker"
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Generate SSH Keys and add it to the project metadata
echo ""
echo "Generating SSH Keys"
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
sed 's/ssh-rsa/root:ssh-rsa/' ~/.ssh/id_rsa.pub > abm-ws-ssh-metadata

# Adding metadata to VMS
echo ""
echo "Adding the ssh key to the other VMs"
gcloud compute instances add-metadata $ABM_CP1 --zone $ZONE --metadata-from-file ssh-keys=abm-ws-ssh-metadata
gcloud compute instances add-metadata $ABM_CP2 --zone $ZONE --metadata-from-file ssh-keys=abm-ws-ssh-metadata
gcloud compute instances add-metadata $ABM_CP3 --zone $ZONE --metadata-from-file ssh-keys=abm-ws-ssh-metadata
gcloud compute instances add-metadata $ABM_WN1 --zone $ZONE --metadata-from-file ssh-keys=abm-ws-ssh-metadata
gcloud compute instances add-metadata $ABM_WN2 --zone $ZONE --metadata-from-file ssh-keys=abm-ws-ssh-metadata

# Deploying ABM
echo ""
echo "Building the configuration for deployment"
bmctl create config -c \$clusterid
cat > bmctl-workspace/\$clusterid/\$clusterid.yaml << EOB
---
gcrKeyPath: /root/bm-gcr.json
sshPrivateKeyPath: /root/.ssh/id_rsa
gkeConnectAgentServiceAccountKeyPath: /root/bm-gcr.json
gkeConnectRegisterServiceAccountKeyPath: /root/bm-gcr.json
cloudOperationsServiceAccountKeyPath: /root/bm-gcr.json
---
apiVersion: v1
kind: Namespace
metadata:
  name: cluster-\$clusterid
---
apiVersion: baremetal.cluster.gke.io/v1
kind: Cluster
metadata:
  name: \$clusterid
  namespace: cluster-\$clusterid
spec:
  type: hybrid
  anthosBareMetalVersion: 1.7.1
  gkeConnect:
    projectID: \$PROJECT_ID
  controlPlane:
    nodePoolSpec:
      clusterName: \$clusterid
      nodes:
      - address: 10.200.7.3
      - address: 10.200.7.4
      - address: 10.200.7.5
  clusterNetwork:
    pods:
      cidrBlocks:
      - 192.168.0.0/16
    services:
      cidrBlocks:
      - 172.26.233.0/24
  loadBalancer:
    mode: bundled
    ports:
      controlPlaneLBPort: 443
    vips:
      controlPlaneVIP: 10.200.7.49
      ingressVIP: 10.200.7.50
    addressPools:
    - name: pool1
      addresses:
      - 10.200.7.50-10.200.7.70
  clusterOperations:
    # might need to be this location
    location: $REGION
    projectID: \$PROJECT_ID
  storage:
    lvpNodeMounts:
      path: /mnt/localpv-disk
      storageClassName: node-disk
    lvpShare:
      numPVUnderSharedPath: 5
      path: /mnt/localpv-share
      storageClassName: standard
---
apiVersion: baremetal.cluster.gke.io/v1
kind: NodePool
metadata:
  name: node-pool-1
  namespace: cluster-\$clusterid
spec:
  clusterName: \$clusterid
  nodes:
  - address: 10.200.7.6
  - address: 10.200.7.7
EOB

echo ""
echo "Creating cluster"
bmctl create cluster -c \$clusterid

EOF
