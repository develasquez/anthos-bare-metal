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

source variables.env
set -eu

echo ""
echo "Preparing to execute with the following values:"
echo "==================================================="
echo "Project ID: $PROJECT_ID"
echo "Region for Deployment: $REGION"
echo "Zone for Deployment: $ZONE"
echo "Network Configuration: $NW_TYPE"
echo "Zone for Deployment: $ZONE"
echo "VM Type: $MACHINE_TYPE"
echo "==================================================="
echo ""
echo "Continuing in 5 seconds. Ctrl+C to cancel"
sleep 5

# Creating Anthos Workstation
echo ""
echo "Creating Anthos Workstation" 
gcloud compute instances create $ABM_WS \
        --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud \
        --zone=$ZONE \
        --boot-disk-size 200G \
        --boot-disk-type pd-ssd \
        --network $VPC_NAME \
        --subnet $SUBNET_NAME \
        --can-ip-forward \
        --no-address \
        --tags abm-gce-v180 \
        --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
        --scopes cloud-platform \
        --machine-type $MACHINE_TYPE || :

# Creating Anthos Control Plane # 1
echo ""
echo "Creating Anthos Control Plane # 1" 
gcloud compute instances create $ABM_CP1 \
        --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud \
        --zone=$ZONE \
        --boot-disk-size 200G \
        --boot-disk-type pd-ssd \
        --network $VPC_NAME \
        --subnet $SUBNET_NAME \
        --can-ip-forward \
        --no-address \
        --tags abm-gce-v180 \
        --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
        --scopes cloud-platform \
        --machine-type $MACHINE_TYPE || :

# Creating Anthos Control Plane # 2
echo ""
echo "Creating Anthos Control Plane # 2" 
gcloud compute instances create $ABM_CP2 \
        --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud \
        --zone=$ZONE \
        --boot-disk-size 200G \
        --boot-disk-type pd-ssd \
        --network $VPC_NAME \
        --subnet $SUBNET_NAME \
        --can-ip-forward \
        --no-address \
        --tags abm-gce-v180 \
        --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
        --scopes cloud-platform \
        --machine-type $MACHINE_TYPE || :

# Creating Anthos Control Plane # 3
echo ""
echo "Creating Anthos Control Plane # 3" 
gcloud compute instances create $ABM_CP3 \
        --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud \
        --zone=$ZONE \
        --boot-disk-size 200G \
        --boot-disk-type pd-ssd \
        --network $VPC_NAME \
        --subnet $SUBNET_NAME \
        --can-ip-forward \
        --no-address \
        --tags abm-gce-v180 \
        --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
        --scopes cloud-platform \
        --machine-type $MACHINE_TYPE || :

# Creating Anthos Worker Node # 1
echo ""
echo "Creating Anthos Worker Node # 1"
gcloud compute instances create $ABM_WN1 \
        --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud \
        --zone=$ZONE \
        --boot-disk-size 200G \
        --boot-disk-type pd-ssd \
        --network $VPC_NAME \
        --subnet $SUBNET_NAME \
        --can-ip-forward \
        --no-address \
        --tags abm-gce-v180 \
        --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
        --scopes cloud-platform \
        --machine-type $MACHINE_TYPE || :

# Creating Anthos Worker Node # 2
echo ""
echo "Creating Anthos Worker Node # 2" 
gcloud compute instances create $ABM_WN2 \
        --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud \
        --zone=$ZONE \
        --boot-disk-size 200G \
        --boot-disk-type pd-ssd \
        --network $VPC_NAME \
        --subnet $SUBNET_NAME \
        --can-ip-forward \
        --no-address \
        --tags abm-gce-v180 \
        --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
        --scopes cloud-platform \
        --machine-type $MACHINE_TYPE || :

echo ""
echo "Testing if the VMs were created correctly"
gcloud compute instances list

echo ""
echo " Creating Firewall Rules for Control Plane"
gcloud compute --project=$PROJECT_ID firewall-rules create abm-gce-v180-controlplane-ports --direction=INGRESS --network=$VPC_NAME --action=ALLOW --source-tags=abm-gce-v180 --target-tags=abm-gce-v180 --rules=tcp:10250,tcp:443,tcp:8443,tcp:8676,tcp:15017 || :

echo ""
echo " Creating Firewall Rules for WorkerNodes"
gcloud compute --project=$PROJECT_ID firewall-rules create abm-gce-v180-workernodes-tcp --direction=INGRESS --network=$VPC_NAME --action=ALLOW --source-tags=abm-gce-v180 --target-tags=abm-gce-v180 --rules=tcp:1-65535 || :
gcloud compute --project=$PROJECT_ID firewall-rules create abm-gce-v180-workernodes-udp --direction=INGRESS --network=$VPC_NAME --action=ALLOW --source-tags=abm-gce-v180 --target-tags=abm-gce-v180 --rules=udp:1-65535 || :
gcloud compute --project=$PROJECT_ID firewall-rules create abm-gce-v180-workernodes-other-protocols --direction=INGRESS --network=$VPC_NAME --action=ALLOW --source-tags=abm-gce-v180 --target-tags=abm-gce-v180 --rules=icmp,sctp,esp,ah || :
gcloud compute --project=$PROJECT_ID firewall-rules create abm-gce-v180-allow-ssh-ingress-from-iap --direction=INGRESS --network=$VPC_NAME --action=ALLOW --source-ranges=35.235.240.0/20 --target-tags=abm-gce-v180 --rules=tcp:22 || :

echo ""
echo "=========================="
echo " VMs deployment completed "
echo "=========================="