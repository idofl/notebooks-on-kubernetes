#!/bin/bash

# Usage deploy.sh [YOUR_PROJECT_ID]

if [ $# -lt 3 ]
  then
    echo "Please provide a project ID, a comma-separated list of deployment ids, and a comma-separated list of user email per deployment"
    echo "ex: deploy.sh [YOUR_PROJECT_ID] deployment1,...,deploymentN userEmail1,...,userEmailN"
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
IFS=',' read -r -a users <<< "$3"

# When Deployments are on the same instance, we need to differentiate their service
port_current=80

mkdir -p ./environments

for i in ${!ids[@]}
do
  id=${ids[$i]}
  user=${users[$i]}  

  echo "Deploying Jupyterlab for ID ${id} and user ${user}, using port ${port_current} for its service."

  cp -r ./jupyterlab ./environments/jupyterlab-${id}
  cp -r ./agent ./environments/agent-${id}

  find ./environments/jupyterlab-${id} -type f -exec sed -i.bak "s/<JUPYTERLAB_ID>/${id}/g" {} \;
  find ./environments/jupyterlab-${id} -type f -exec sed -i.bak "s/<SERVICE_PORT>/${port_current}/g" {} \;
  find ./environments/jupyterlab-${id} -type f -exec sed -i.bak "s/<PROJECT_ID>/${PROJECT_ID}/g" {} \;
  find ./environments/jupyterlab-${id} -type f -exec sed -i.bak "s/<GCS_NOTEBOOK_BUCKET>/${GCS_NOTEBOOK_BUCKET}/g" {} \;

  find ./environments/agent-${id} -type f -exec sed -i.bak "s/<JUPYTERLAB_ID>/${id}/g" {} \;
  find ./environments/agent-${id} -type f -exec sed -i.bak "s/<JUPYTERLAB_USER>/${user}/g" {} \;
  find ./environments/agent-${id} -type f -exec sed -i.bak "s/<PROJECT_ID>/${PROJECT_ID}/g" {} \;
  
  kubectl apply -f environments/jupyterlab-${id}/deployment.yaml
  kubectl apply -f environments/jupyterlab-${id}/service.yaml
  kubectl apply -f environments/agent-${id}/deployment.yaml

  #port_current=$((port_current+1))
done