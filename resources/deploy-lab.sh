# Parameters
sourceimage=${1:-'https://bootcampbr.blob.core.windows.net/vmvhd/labosdisk.vhd?sp=r&st=2018-06-16T00:59:19Z&se=2018-06-18T08:59:19Z&spr=https&sv=2017-11-09&sig=ye%2FoEkbdAK8uNBMQtPVZi4r%2FUztsl7Fp%2BT2Z08hQww0%3D&sr=b'}
vmuser=${2:-'azureuser'}
vmpassword=${3:-'P@ssw0rd0123'}
location=${4:-'eastus'}
resourcegroup=${5:-'devops-bootcamp'}
# Constants
accountname=$(echo gdvpblob$(od -vAn -N4 -tu4 < /dev/urandom) | sed 's/ //g')
vmname=bootcampvm

set -e # on error exit

echo Started!

# Resource Group
echo Creating resource group $resourcegroup on $location...
az group create --name $resourcegroup --location $location >/dev/null
echo Resource group $resourcegroup created.

# Storage Account
echo Creating storage account $accountname on $resourcegroup...
az storage account create -g $resourcegroup -n $accountname >/dev/null
destination=$(az storage account show -g $resourcegroup -n $accountname --query primaryEndpoints.blob -o tsv)vhd/labosdisk.vhd
destkey=$(az storage account keys list -g $resourcegroup -n $accountname --query [0].value -o tsv)
echo Storage created.

# Disk Copy
echo Starting copy of Lab VHD disk to $destination...
azcopy --source $sourceimage --destination $destination --dest-key $destkey
echo VHD disk copied.

# Lab VM
echo Creating your VM...
az vm create    -n $vmname \
                -g $resourcegroup \
                --attach-os-disk $destination \
                --os-type linux \
                --size Standard_D2_v2 \
                --use-unmanaged-disk \
                >/dev/null
echo VM created.

echo Updating Username and Password...
az vm user update \
    -n $vmname \
    -g $resourcegroup \
    -u $vmuser \
    -p $vmpassword \
    >/dev/null
echo Finished updating Username and Password.

echo Updating Firewall rules...
az vm open-port -g $resourcegroup -n $vmname --port 3000 --priority 1001 >/dev/null
az vm open-port -g $resourcegroup -n $vmname --port 8080 --priority 1002 >/dev/null
echo Finished updating Firewall rules.

echo Getting your VM public IP...
vmip=$(az vm list-ip-addresses -n $vmname -g $resourcegroup --query [0].virtualMachine.network.publicIpAddresses[0].ipAddress -o tsv)
echo Access your VM using:
echo ssh $vmuser@$vmip

echo Finished!

exit 0
