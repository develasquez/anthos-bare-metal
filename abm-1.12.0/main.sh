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

source ./variables.env;
source ./create_fw.sh;
source ./create_vm.sh;
source ./node_setup.sh;
source ./set_iam_roles.sh;


# Enable APIs and Creating Service Account
echo ""
echo "============================================="
echo " Enabling required APIs and Service Accounts "
echo "============================================="

# Enable the required APIs
echo ""
echo "Enabling APIs"

gcloud services enable \
    anthos.googleapis.com \
    anthosgke.googleapis.com \
    cloudresourcemanager.googleapis.com \
    container.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    serviceusage.googleapis.com \
    stackdriver.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com

set_iam_roles;

# Validate the network configuration
echo ""
echo "============================"
echo " Pre Checks for VM Creation "
echo "============================"

create_vm $ABM_WS $MACHINE_TYPE $VPC_NAME $SUBNET_NAME &
create_vm $ABM_CP1 $MACHINE_TYPE $VPC_NAME $SUBNET_NAME &
create_vm $ABM_CP2 $MACHINE_TYPE $VPC_NAME $SUBNET_NAME &
create_vm $ABM_CP3 $MACHINE_TYPE $VPC_NAME $SUBNET_NAME &
create_vm $ABM_WN1 $MACHINE_TYPE $VPC_NAME $SUBNET_NAME &
create_vm $ABM_WN2 $MACHINE_TYPE $VPC_NAME $SUBNET_NAME;

create_fw $VPC_NAME;


# Validate the network configuration
echo ""
echo "============================"
echo " Set XVLAN on Nodes         "
echo "============================"


setup_node $ABM_WS 2 &
setup_node $ABM_CP1 3 &
setup_node $ABM_CP2 4 &
setup_node $ABM_CP3 5 &
setup_node $ABM_WN1 6 &
setup_node $ABM_WN2 7;


echo ""
echo "======================"
echo " Deployment Completed "
echo "======================"
echo ""
echo 'To continue setting up Anthos please run "chmod +x deployment-anthos.sh" and then run "./deployment-anthos.sh"'
echo ""



