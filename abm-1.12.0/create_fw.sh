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


create_fw(){
    VPC_NAME=$1

    echo ""
    echo " Creating Firewall Rules for Control Plane"
    gcloud compute --project=$PROJECT_ID firewall-rules create anthos-vm-controlplane-ports --direction=INGRESS --network=$VPC_NAME --action=ALLOW --source-tags=anthos-vm --target-tags=anthos-vm --rules=tcp:10250,tcp:443,tcp:8443,tcp:8676,tcp:15017 || :

    echo ""
    echo " Creating Firewall Rules for WorkerNodes"
    gcloud compute --project=$PROJECT_ID firewall-rules create anthos-vm-workernodes-tcp --direction=INGRESS --network=$VPC_NAME --action=ALLOW --source-tags=anthos-vm --target-tags=anthos-vm --rules=tcp:1-65535 || :
    gcloud compute --project=$PROJECT_ID firewall-rules create anthos-vm-workernodes-udp --direction=INGRESS --network=$VPC_NAME --action=ALLOW --source-tags=anthos-vm --target-tags=anthos-vm --rules=udp:1-65535 || :
    gcloud compute --project=$PROJECT_ID firewall-rules create anthos-vm-workernodes-other-protocols --direction=INGRESS --network=$VPC_NAME --action=ALLOW --source-tags=anthos-vm --target-tags=anthos-vm --rules=icmp,sctp,esp,ah || :
    gcloud compute --project=$PROJECT_ID firewall-rules create anthos-vm-allow-ssh-ingress-from-iap --direction=INGRESS --network=$VPC_NAME --action=ALLOW --source-ranges=35.235.240.0/20 --target-tags=anthos-vm --rules=tcp:22 || :

}