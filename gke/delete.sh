#!/bin/bash

# Common to all Jupyterlab enviornments.
kubectl delete -f agent/sa.yaml
kubectl delete -f agent/role.yaml
kubectl delete -f agent/rolebinding.yaml

# Represents the list of users.
ids=( "aaa" "bbb" "ccc" "ddd")

for id in "${ids[@]}"
do
  kubectl delete -f environments/jupyterlab-${id}/deployment.yaml
  kubectl delete -f environments/jupyterlab-${id}/service.yaml
  kubectl delete -f environments/agent-${id}/deployment.yaml
  kubectl delete configmaps inverse-proxy-config-${id}
done
