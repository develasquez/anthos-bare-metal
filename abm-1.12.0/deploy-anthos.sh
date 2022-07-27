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
gsutil cp gs://anthos-baremetal-release/bmctl/1.12.0/linux-amd64/bmctl .
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
bmctl create config -c ${CLUSTER_ID}

bmctl-workspace/${CLUSTER_ID}/${CLUSTER_ID}.yaml 

sed -i 's/{CLUSTER_ID}/${CLUSTER_ID}/g' admin-cluster.yaml > admin-cluster.yaml
sed -i 's/{PROJECT_ID}/${PROJECT_ID}/g' admin-cluster.yaml > admin-cluster.yaml
sed -i 's/{REGION}/${REGION}/g' admin-cluster.yaml > bmctl-workspace/${CLUSTER_ID}/${CLUSTER_ID}.yaml 


echo ""
echo "Creating cluster"
bmctl create cluster -c ${CLUSTER_ID}