#!/bin/bash

if [[ -z $GOVC_URL || -z $GOVC_USERNAME || -z $GOVC_PASSWORD || -z $GOVC_INSECURE || -z $M4C_VCENTER_PWD || -z $M4C_VCENTER_USER ]]; then
  echo 'Following environment variables need to be set before running the script
  GOVC_URL          # Vcenter URL or IP
  GOVC_USERNAME     # User to use to connect to the Vcenter and create the M4CE user and import the OVA
  GOVC_PASSWORD     # Password of the user above
  GOVC_INSECURE     # True or false 
  M4C_VCENTER_USER  # Vcetner User name to create for M4CE migration tasks 
  M4C_VCENTER_DOMAIN  # Vcetner User name to create for M4CE migration tasks
  M4C_VCENTER_PWD   # Password of the user above
  '
  exit 1
fi


govc role.create  Velostrata5 $(echo 'Global.DisableMethods
Global.EnableMethods
VirtualMachine.Config.ChangeTracking
VirtualMachine.Interact.PowerOff
VirtualMachine.Provisioning.DiskRandomRead
VirtualMachine.Provisioning.GetVmFiles
VirtualMachine.State.CreateSnapshot
VirtualMachine.State.RemoveSnapshot')

 govc sso.user.create  -p $M4C_VCENTER_PWD -R Velostrata5 $M4C_VCENTER_USER

 govc permissions.set  -principal $M4C_VCENTER_USER@$M4C_VCENTER_DOMAIN   -propagate=true  -role=Velostrata5

## Download and create the M4C connector

# Download the connector
wget https://storage.googleapis.com/vmmigration-public-artifacts/M4C.ova

# Fetch the public key value you generated

 PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub  | awk  '{print $1 " " $2}')

# generate JSON spec file to import the OVA
# In this case, we will use DHCP for the network configuration
# and the SSH key generated earlier to be able to connect to 
# the VM

cat >> M4C.json <<EOF
{
    "DiskProvisioning": "thin",
    "IPAllocationPolicy": "dhcpPolicy",
    "IPProtocol": "IPv4",
    "InjectOvfEnv": false,
    "MarkAsTemplate": false,
    "Name": "M4CEv5-connector",
    "NetworkMapping": [
        {
            "Name": "VM Network",
            "Network": "internal management"
        }
    ],
    "PowerOn": true,
    "PropertyMapping": [
        {
            "Key": "public-keys",
            "Value": "$PUBLIC_KEY"
        },
        {
            "Key": "hostname",
            "Value": "migrate-appliance"
        },
        {
            "Key": "ip0",
            "Value": "0.0.0.0"
        },
        {
            "Key": "netmask0",
            "Value": "0.0.0.0"
        },
        {
            "Key": "gateway",
            "Value": "0.0.0.0"
        },
        {
            "Key": "DNS",
            "Value": ""
        },
        {
            "Key": "proxy",
            "Value": ""
        },
        {
            "Key": "route0",
            "Value": ""
        }
    ],
    "WaitForIP": false
}

EOF

# Set the GOVC variables and import the OVA


govc import.ova --options=M4C.json M4C.ova
rm M4C*
# Connect to the instance 
M4CE_IP=$(govc vm.ip M4CEv5)
ssh-keygen -f "/home/labUser/.ssh/known_hosts" -R $M4CE_IP
ssh admin@$M4CE_IP -i ~/.ssh/id_rsa
