#!/bin/bash

# Usage deploy.sh [YOUR_PROJECT_ID]

if [ $# -lt 2 ]
  then
    echo "Please provide a project ID and comma-separated list of deployment ids"
    echo "ex: deploy.sh [YOUR_PROJECT_ID] deployment1,...,deploymentN"
    exit 1
fi

PROJECT_ID=$1
GCS_NOTEBOOK_BUCKET="${PROJECT_ID}-notebooks-gke"

gsutil mb "gs://${GCS_NOTEBOOK_BUCKET}"

# Common to all Jupyterlab enviornments.
kubectl apply -f agent/sa.yaml
kubectl apply -f agent/role.yaml
kubectl apply -f agent/rolebinding.yaml

# Represents the list of users.
IFS=',' read -r -a ids <<< "$2"

# When Deployments are on the same instance, we need to differentiate their service
port_current=80

mkdir -p ./environments

for id in "${ids[@]}"
do
  echo "Deploying Jupyterlab for ${id} using port ${port_current} for its service."

  cp -r ./jupyterlab ./environments/jupyterlab-${id}
  cp -r ./agent ./environments/agent-${id}

  find ./environments/jupyterlab-${id} -type f -exec sed -i.bak "s/<JUPYTERLAB_ID>/${id}/g" {} \;
  find ./environments/jupyterlab-${id} -type f -exec sed -i.bak "s/<SERVICE_PORT>/${port_current}/g" {} \;  
  find ./environments/jupyterlab-${id} -type f -exec sed -i.bak "s/<PROJECT_ID>/${PROJECT_ID}/g" {} \;
  find ./environments/jupyterlab-${id} -type f -exec sed -i.bak "s/<GCS_NOTEBOOK_BUCKET>/${GCS_NOTEBOOK_BUCKET}/g" {} \;  

  find ./environments/agent-${id} -type f -exec sed -i.bak "s/<JUPYTERLAB_ID>/${id}/g" {} \;
  find ./environments/agent-${id} -type f -exec sed -i.bak "s/<PROJECT_ID>/${PROJECT_ID}/g" {} \;
  
  kubectl apply -f environments/jupyterlab-${id}/deployment.yaml
  kubectl apply -f environments/jupyterlab-${id}/service.yaml
  kubectl apply -f environments/agent-${id}/deployment.yaml

  port_current=$((port_current+1))
done