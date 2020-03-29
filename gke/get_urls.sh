#!/bin/bash

ids=( "aaa" "bbb" "ccc" "ddd")

for id in "${ids[@]}"
do
  echo $(kubectl describe configmap inverse-proxy-config-${id} | grep googleusercontent.com)
done