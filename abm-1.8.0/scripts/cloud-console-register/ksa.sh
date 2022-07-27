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

# This script is intended for logging in using a bearer token
source ./variables.env
export KUBECONFIG=$HOME/bmctl-workspace/$clusterid/$clusterid-kubeconfig
kubectl get nodes

# Baseline
kubectl create serviceaccount ${K8S_SERVICE_ACCOUNT}

# Read Only Access to the K8s Service Account
# kubectl create clusterrolebinding ksa-viewer-$clusterid --clusterrole view --serviceaccount default:${K8S_SERVICE_ACCOUNT}
# kubectl create clusterrolebinding cloud-console-reader --clusterrole cloud-console-reader --serviceaccount default:${K8S_SERVICE_ACCOUNT}

# Admin Access to the K8s Service Account
kubectl create clusterrolebinding cloud-console-reader --clusterrole cluster-admin --serviceaccount default:${K8S_SERVICE_ACCOUNT}

# Get Access to Token
SECRET_NAME=$(kubectl get serviceaccount ${K8S_SERVICE_ACCOUNT} -o jsonpath='{$.secrets[0].name}')
kubectl get secret ${SECRET_NAME} -o jsonpath='{$.data.token}' | base64 --decode