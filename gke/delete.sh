#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Please provide a comma-separated list of deployment ids"
    echo "ex: delete.sh deployment1,...,deploymentN"
    exit 1
fi

# Common to all Jupyterlab enviornments.
# TODO: delete the service account if all deployments had been deleted
kubectl delete -f agent/sa.yaml
kubectl delete -f agent/role.yaml
kubectl delete -f agent/rolebinding.yaml

# Represents the list of users.
IFS=',' read -r -a ids <<< "$1"

for id in "${ids[@]}"
do
  kubectl delete -f environments/jupyterlab-${id}/deployment.yaml
  kubectl delete -f environments/jupyterlab-${id}/service.yaml
  kubectl delete -f environments/agent-${id}/deployment.yaml
  kubectl delete configmaps inverse-proxy-config-${id}
done
