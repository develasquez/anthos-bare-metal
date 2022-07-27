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

echo ""
echo "==================================================="
echo " Preparing to execute ABM on GCE Deployment Script "
echo "==================================================="
echo ""
echo "Continuing in 5 seconds. Ctrl+C to cancel"
sleep 5

source ./variables.env
set -eu

echo ""
echo "============================================="
echo " Granting execution privileges to the script "
echo "============================================="
chmod +x scripts/for-vms/gce-deployment-default-nw.sh
chmod +x scripts/for-vms/gce-deployment-shared-vpc.sh
chmod +x scripts/landing/landing-zone-security.sh
chmod +x scripts/for-vms/controlplane-1.sh
chmod +x scripts/for-vms/controlplane-2.sh
chmod +x scripts/for-vms/controlplane-3.sh
chmod +x scripts/for-vms/workernode-1.sh
chmod +x scripts/for-vms/workernode-2.sh
chmod +x scripts/for-vms/workstation.sh
sleep 3

# Enable APIs and Creating Service Account
echo ""
echo "============================================="
echo " Enabling required APIs and Service Accounts "
echo "============================================="
./scripts/landing/landing-zone-security.sh
sleep 3

# Validate the network configuration
echo ""
echo "============================"
echo " Pre Checks for VM Creation "
echo "============================"

if [ "$NW_TYPE" = "default-vpc" ];then 
  ./scripts/for-vms/gce-deployment-default-nw.sh
else
  ./scripts/for-vms/gce-deployment-shared-vpc.sh 
fi
sleep 3

# Setting up VXLAN on VMs
echo ""
echo " Setting UP $ABM_WS "
./scripts/for-vms/workstation.sh
sleep 3

echo ""
echo " Setting UP $ABM_CP1 "
./scripts/for-vms/controlplane-1.sh
sleep 3

echo ""
echo " Setting UP $ABM_CP2 "
./scripts/for-vms/controlplane-2.sh
sleep 3

echo ""
echo " Setting UP $ABM_CP3 "
./scripts/for-vms/controlplane-3.sh
sleep 3

echo ""
echo " Setting UP $ABM_WN1 "
./scripts/for-vms/workernode-1.sh
sleep 3

echo ""
echo " Setting UP $ABM_WN2 "
./scripts/for-vms/workernode-2.sh
sleep 3

echo ""
echo "======================"
echo " Deployment Completed "
echo "======================"
echo ""
echo 'To continue setting up Anthos please run "chmod +x deployment-anthos.sh" and then run "./deployment-anthos.sh"'
echo ""