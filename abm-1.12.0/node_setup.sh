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
NAME=$1
IP=$2

echo "This script must be executed from the Cloud Shell" 
set -eu

echo ""
echo "Copying script into $NAME"
gcloud beta compute scp variables.env root@$NAME:~ --zone "$ZONE" --tunnel-through-iap --project "$PROJECT_ID"
gcloud beta compute scp vxlan.sh root@$NAME:~ --zone "$ZONE" --tunnel-through-iap --project "$PROJECT_ID"

# SSH into the VM as root
gcloud beta compute ssh --zone "$ZONE" "root@$NAME" --tunnel-through-iap --project "$PROJECT_ID" << EOF
chmod +x vxlan.sh
./vxlan.sh ${IP}
EOF