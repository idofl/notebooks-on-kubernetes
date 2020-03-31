#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Please provide a comma-separated list of deployment ids"
    echo "ex: delete.sh deployment1,...,deploymentN"
    exit 1
fi

IFS=',' read -r -a ids <<< "$1"

for id in "${ids[@]}"
do
  echo $(kubectl describe configmap inverse-proxy-config-${id} | grep googleusercontent.com)
done