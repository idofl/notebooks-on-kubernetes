## Deploy
To deploy the infrastructure:

1. Set up your variables

    ```sh
    # Your working project id. ex: my_project
    PROJECT_ID=[YOUR_PROJECT_ID]
    # Comma-separated list of deployments. ex: user1,deployment2,test3
    JUPYTERLAB_IDS=[YOUR_IDS]
    ```

1. Deploy

    ```sh
    bash deploy.sh ${PROJECT_ID} ${JUPYTERLAB_IDS}
    ```

1. Wait for deployment to be done

1. Get Inverting proxy URLs

    ```sh
    bash get_urls ${JUPYTERLAB_IDS}
    ```

1. Access a Notebook using the relevant URL.
