#!/bin/bash



if ls networks_base.tf
then
    echo "network scripts present"
    if [ $# -eq 1 ]
    then
        echo "disabling them"
        for current_network_script in $(ls network*)
        do
            mv $current_network_script ${current_network_script%.*}
        done
    fi
else
    echo "network scripts  absent, enabling them"
    for current_network_script in $(ls network*)
    do
        mv $current_network_script ${current_network_script}.tf
    done
fi 

