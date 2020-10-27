#!/usr/bin/env bash
# Copyright 2020 The Jetstack cert-manager contributors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail


TMP_DIR=`mktemp -d`
# check if tmp dir was created
if [[ ! "$TMP_DIR" || ! -d "$TMP_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

echo "Downloading nginxinc/kubernetes-ingress..."
git clone https://github.com/nginxinc/kubernetes-ingress/ "$TMP_DIR"
cd "$TMP_DIR"
git checkout v1.8.1

echo "Installing nginxinc/kubernetes-ingress..."
kubectl apply -f deployments/common/ns-and-sa.yaml
kubectl apply -f deployments/rbac/rbac.yaml
kubectl apply -f deployments/common/default-server-secret.yaml
kubectl apply -f deployments/common/nginx-config.yaml

kubectl apply -f deployments/common/vs-definition.yaml
kubectl apply -f deployments/common/vsr-definition.yaml
kubectl apply -f deployments/common/ts-definition.yaml
kubectl apply -f deployments/common/policy-definition.yaml
kubectl apply -f deployments/common/gc-definition.yaml
kubectl apply -f deployments/common/global-configuration.yaml

kubectl apply -f deployments/daemon-set/nginx-ingress.yaml
kubectl apply -f deployments/service/nodeport.yaml

echo "Waiting for pods to be ready"
kubectl rollout status ds/nginx-ingress -n nginx-ingress
