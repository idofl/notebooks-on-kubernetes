# Common to all Jupyterlab enviornments.
kubectl apply -f agent/sa.yaml
kubectl apply -f agent/role.yaml
kubectl apply -f agent/rolebinding.yaml

# Represents the list of users.
ids=( "aaa" "bbb" "ccc" "ddd")

# When Deployments are on the same instance, we need to differentiate their service
port_current=80

mkdir -p ./environments

for id in "${ids[@]}"
do
  echo "Deploying Jupyterlab for ${id} using port ${port_current} for its service."

  cp -r ./jupyterlab ./environments/jupyterlab-${id}
  cp -r ./agent ./environments/agent-${id}

  find ./environments/jupyterlab-${id} -type f -exec sed -i.bak "s/<JUPYTERLAB_ID>/${id}/g" {} \;
  find ./environments/agent-${id} -type f -exec sed -i.bak "s/<JUPYTERLAB_ID>/${id}/g" {} \;

  find ./environments/jupyterlab-${id} -type f -exec sed -i.bak "s/<SERVICE_PORT>/${port_current}/g" {} \;

  kubectl apply -f environments/jupyterlab-${id}/deployment.yaml
  kubectl apply -f environments/jupyterlab-${id}/service.yaml
  kubectl apply -f environments/agent-${id}/deployment.yaml

  port_current=$((port_current+1))
done