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

# Loading variables
echo ""
echo "Loanding .env file"
source ./variables.env
export i=3

#Install required packages
echo ""
echo "Installing required packages"
apt-get -qq update > /dev/null
apt-get -qq install -y jq > /dev/null

# Configure VXLAN
echo ""
echo "Getting existing nodes IP address"
declare -a VMs=("$ABM_WS" "$ABM_CP1" "$ABM_CP2" "$ABM_CP3" "$ABM_WN1" "$ABM_WN2")
declare -a IPs=()

for vm in "${VMs[@]}"
do
    IP=$(gcloud compute instances describe $vm --zone ${ZONE} \
         --format='get(networkInterfaces[0].networkIP)')
    IPs+=("$IP")
done

echo ""
echo "Configuring VXLAN"
ip link add vxlan0 type vxlan id 42 dev ens4 dstport 0
current_ip=$(ip --json a show dev ens4 | jq '.[0].addr_info[0].local' -r)
echo "VM IP address is: $current_ip"
for ip in ${IPs[@]}; do
    if [ "$ip" != "$current_ip" ]; then
        bridge fdb append to 00:00:00:00:00:00 dst $ip dev vxlan0
    fi
done
ip addr add 10.200.6.$i/24 dev vxlan0
echo ""
echo "Enabling VXLAN"
ip link set up dev vxlan0

echo ""
echo "Disabling AppArmor Service"
systemctl stop apparmor.service
systemctl disable apparmor.service