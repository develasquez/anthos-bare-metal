# This is not an official Google project.

This script is for **educational purposes only**, is **not certified** and is **not recommended** for production environments.

## Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

---

This is not an official Google project.

---

## Clone this repository to begin

     git clone https://github.com/manueltorresc/anthos-baremetal-gce.git

## Architecture diagram
The scripts configure Compute Engine with the following resources:

- Six VMs to deploy the hybrid cluster:
     - One admin VM used to deploy the hybrid cluster to the other machines.
     - Three VMs for the three control plane nodes needed to run the hybrid cluster control plane.
     - Two VMs for the two worker nodes needed to run workloads on the hybrid cluster.
- A VxLAN overlay network between all the nodes to emulate L2 connectivity.
- SSH access to the control-plane and worker nodes from the admin VM.

## Set all the deployment parameters on the variables.env file using nano or vim

     nano variables.env

or

     vim variables.env

## This script must be executed from Cloud Shell
For GCE Infra deployment please execute

     chmod +x deployment-infra.sh
     ./deployment-infra.sh

For Anthos Software deployment on GCE please execute
     
     chmod +x deployment-anthos.sh
     ./deployment-anthos.sh

## Next Steps (Optional)
- Login into the cluster, documentation [here](https://cloud.google.com/anthos/multicluster-management/console/logging-in#logging_in_using_a_bearer_token)
- Deploy a Sample App, documentation [here](https://cloud.google.com/anthos/clusters/docs/on-prem/1.8/how-to/deploy-first-app)