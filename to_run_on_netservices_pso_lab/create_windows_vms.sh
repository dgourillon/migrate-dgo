#!/bin/bash

OVF_bucket=psolab-ovas-dgo

## gsutil requires a project_id to be set (skip if you already have done it)
project_id_default=$(gcloud projects list | grep migrate | tail -1 | awk '{print $1}')
gcloud config set project $project_id_default 

for current_ovf in $(gsutil ls gs://$OVF_bucket/ | grep 'windows.*base.*' | awk -F '/' '{print $4}' | grep ovf |  awk -F '.' '{print $1}')
do
    echo "creating $current_ovf VM"
    gsutil cp gs://$OVF_bucket/$current_ovf* .
    govc import.ovf --options=$current_ovf.json $current_ovf.ovf
    rm $current_ovf*
done
