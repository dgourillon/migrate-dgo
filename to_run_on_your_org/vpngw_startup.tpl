#! /bin/bash 
sudo su -
sed -i 's/mtb/${mtb_number}/g' /etc/ipsec.d/gcp.conf
service strongswan restart

