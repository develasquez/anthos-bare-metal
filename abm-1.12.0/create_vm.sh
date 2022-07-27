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

create_vm() {

    NAME=$1
    MACHINE_TYPE=$2
    VPC_NAME=$3
    SUBNET_NAME=$4
    

    echo ""
    echo "Creating Anthos Workstation" 
    gcloud compute instances create $ABM_WS \
            --image-family=ubuntu-2204-lts --image-project=ubuntu-os-cloud \
            --zone=$ZONE \
            --boot-disk-size 256G \
            --boot-disk-type pd-ssd \
            --network $VPC_NAME \
            --subnet $SUBNET_NAME \
            --can-ip-forward \
            --no-address \
            --tags anthos-vm \
            --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
            --scopes cloud-platform \
            --machine-type $MACHINE_TYPE || :
}