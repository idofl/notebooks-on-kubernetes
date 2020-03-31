## Comments and questions:
Currently, this is not working as scale due to the inverting proxy providing one URL per node and not per deployment.

For details please see the [article](https://blog.kovalevskyi.com/running-cloud-ai-platform-notebook-on-google-kubernetes-engine-8e161f1b1dc0)

## Deploy Kubernetes

1. Set variables

    ```sh
    PROJECT_ID="mam-nooage"
    CLUSTER_NAME="kupyterhub"
    ZONE="us-central1-a"
    ```

1. Install tools

    ```sh
    gcloud components install kubectl --quiet
    ```

1. Create the cluster

    ```sh
    gcloud beta container clusters create ${CLUSTER_NAME} \
    --project ${PROJECT_ID} \
    --zone ${ZONE} \
    --release-channel regular \
    --enable-ip-alias \
    --scopes "https://www.googleapis.com/auth/cloud-platform"
    ```

1. Configure kubectl access 

    ```sh
    gcloud container clusters get-credentials ${CLUSTER_NAME} \
    --project ${PROJECT_ID} \
    --zone ${ZONE}
    ```

## Deploy Notebook Servers

To deploy one or several Notebook servers on GKE, do the following:

1. Set your variables

    ```sh
    PROJECT_ID="mam-nooage"
    
    DOCKER_IMAGE_AGENT="gcr.io/${PROJECT_ID}/agent:gke"
    DOCKER_IMAGE_JUPYTERLAB="gcr.io/${PROJECT_ID}/ain:gke"

    DEPLOYMENT_NAMES_LIST="aaa,bbb,ccc,ddd"
    ```

1. Create a Docker image for JupyterLab using an AI Notebook base image or your own.

    ```sh
    gcloud builds submit --tag  ${DOCKER_IMAGE_JUPYTERLAB} ./docker/jupyterlab
    ```

1. Update the image reference for [JupyterLab] (gke/jupyterlab/deployment.yaml)

    ```sh
    # You can do manually in the file
    # sed -i "s/<DOCKER_IMAGE_JUPYTERLAB>/${DOCKER_IMAGE_JUPYTERLAB}/g" "gke/jupyterlab/deployment.yaml"
    ```

1. Create a Docker image for JupyterLab using an AI Notebook base image or your own.

    ```sh
    gcloud builds submit --tag  ${DOCKER_IMAGE_AGENT} ./docker/agent
    ```

1. Update the docker image for the [agent] (gke/agent/deployment.yaml)

    ```sh
    # You can do manually in the file
    # sed -i "s/<DOCKER_IMAGE_AGENT>/${DOCKER_IMAGE_AGENT}/g" "gke/agent/deployment.yaml"
    ```

1. Run the deploy script. The deploy script creates temporary GKE yaml files for each ids then deploy.

    ```sh
    cd gke
    bash deploy.sh ${PROJECT_ID} ${DEPLOYMENT_NAMES_LIST}
    ```

1. Wait for deployment to be done

    ```sh
    kubectl get pods
    ```

1. Get Inverting proxy URLs

    ```sh
    bash get_urls ${DEPLOYMENT_NAMES_LIST}
    ```

1. Access a Notebook using the relevant URL.


## Delete

1. Deployments

    ```sh
    bash delete.sh ${DEPLOYMENT_NAMES_LIST}
    ```

1. Kubernetes Engine

    TODO