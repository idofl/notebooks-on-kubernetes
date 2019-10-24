# Running Cloud AI Platform Notebooks On Kubernetes (GKE)

## Pre requirenments
* You need to have Cloud AI Platform Notebooks compatible container. (we will use: gcr.io/deeplearning-platform-release/base-cpu:m34)
* You will need to build your proxy agent container this can be done with the following commands

```bash
cd agent
AGENT_TAG=... # pur your agent tag
docker build . -t "${AGENT_TAG}"
docker push "${AGENT_TAG}"
```

* You have a cluster (name of the cluster will be in the variable ${CLUSTER})
* You have preconfigured kubectl command. For GKE you can do it like this:
```bash
gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}" --project "${PROJECT}"
```

## Setup JupyterLab

* Put your Cloud AI Platform Notebooks compatible container in ```jupyterlab-deployment.yaml``` in the following place:

```yaml
      containers:
      - image: gcr.io/deeplearning-platform-release/base-cpu:m34
```
* Deploy it:

```bash
kubectl apply -f jupyterlab-deployment.yaml
```
* Wait some time and verify the deployment:
```bash
➜  notebooks-on-kubernetes git:(master) ✗ kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
jupyterlab   1/1     1            1           2m56s
➜  notebooks-on-kubernetes git:(master) ✗ kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
jupyterlab-b59c98c67-h4sj2   1/1     Running   0          3m23s
```

* Manually test JupyterLab by port forwarding:
```bash
kubectl port-forward jupyterlab-b59c98c67-h4sj2 8080:8080
```

* Create service:

```bash
➜  notebooks-on-kubernetes git:(master) ✗ kubectl apply -f jupyterlab-service.yaml
service/jupyterlab created
➜  notebooks-on-kubernetes git:(master) ✗ kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
jupyterlab   ClusterIP   10.24.6.33   <none>        80/TCP    7s
kubernetes   ClusterIP   10.24.0.1    <none>        443/TCP   14m
```

## Connect JupyterLab to Proxy

* Create dedicate service account for proxy agent:
```bash
kubectl apply -f ./agent-sa.yaml
```
* Create dedicated role for proxy agent:
```bash
kubectl apply -f ./agent-role.yaml
```

* Bind role to the service account:
```bash
kubectl apply -f ./agent-rolebinding.yaml
```

* If you have changed service name, make sure that you correclty have specified variables in ```attempt-register-vm-on-proxy.sh``` , specifically here:
```
        --host="${JUPYTERLAB_PORT_80_TCP_ADDR}:${JUPYTERLAB_SERVICEPORT}" \
```

* Deploy the agent:
```bash
kubectl apply -f ./agent-deployment.yaml
```

* get logs from the agent to get the link:
```bash
➜  agent git:(master) ✗ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
jupyterlab-b59c98c67-h4sj2     1/1     Running   0          16m
proxy-agent-565c9b8df7-gvsfv   1/1     Running   0          56s


```
