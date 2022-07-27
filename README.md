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

## Clone this repository to begin

     git clone https://github.com/metorresc/anthos-baremetal-gce.git

## Architecture diagram
The scripts configure Compute Engine with the following resources:

- Six VMs to deploy the hybrid cluster:
     - One admin VM used to deploy the hybrid cluster to the other machines.
     - Three VMs for the three control plane nodes needed to run the hybrid cluster control plane.
     - Two VMs for the two worker nodes needed to run workloads on the hybrid cluster.
- A VxLAN overlay network between all the nodes to emulate L2 connectivity.
- SSH access to the control-plane and worker nodes from the admin VM.
- No External IP assigned for GCE.
- Single zone deployment.

![ABM Architecture](https://cloud.google.com/anthos/clusters/docs/bare-metal/1.8/images/abm_gcp_infra.svg)

## Execution requirements
Here is a list of the requirements depending on the scenario.

If you are using a project **without** a shared vpc:
- Pick up a Google Cloud Region for deployment.
- Create a Cloud Router in the selected region, an example of how to do it is available at the following [link](https://cloud.google.com/network-connectivity/docs/router/how-to/creating-routers#before_you_begin)
- Create a Cloud NAT instance in the selected region to grant Internet access to the GCE VMs, an example of how to do it is available at the following [link](https://cloud.google.com/nat/docs/using-nat#set_up_a_simple_configuration)
- Run this script from Cloud Shell

If you are using a project **with** a shared vpc:
- Pick up a Google Cloud Region for deployment.
- Validate that your existing VPC has a Cloud Router in the selected region, or create a new one using this [link](https://cloud.google.com/network-connectivity/docs/router/how-to/creating-routers#before_you_begin)
- Validate that your existing VPC has a Cloud NAT in the selected region, or create a new one using this [link](https://cloud.google.com/nat/docs/using-nat#set_up_a_simple_configuration)
- Run this script from Cloud Shell

## Execution Tips
- This script is for **educational purpose only**.
- There is three folders according to the specific Anthos on Bare Metal release.
- Each folder contains a separate **variables.env** file to setup each version.
- Pick the desired release and follow the instructions.
