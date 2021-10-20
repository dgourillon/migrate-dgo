MY_NETWORK="hub-network"
MY_NETWORK_PROJECT="net-hub-project-fwtc"

PEERING_NAME="migrate-network"
project_id=$(gcloud config get-value project)

gcloud compute networks peerings delete $PEERING_NAME --network $MY_NETWORK --project $MY_NETWORK_PROJECT 

gcloud compute networks peerings create $PEERING_NAME --peer-project $project_id --network $MY_NETWORK --peer-network "migrate-network" --export-custom-routes --import-custom-routes --project $MY_NETWORK_PROJECT
