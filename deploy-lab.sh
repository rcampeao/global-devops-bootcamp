# Parameters
resourcegroup=devops-bootcamp
location=${1:-'eastus2'}
accountname=$(echo gdvpblob$(od -vAn -N4 -tu4 < /dev/urandom) | sed 's/ //g')
sourceimage='https://md-g2lj3jhvdx1x.blob.core.windows.net/qqk5lvrzxvtg/abcd?sv=2017-04-17&sr=b&si=2f27476d-f404-4b91-a8bb-4d4ad701e2b3&sig=b8GdInjLjPClPVyImvxWl0kyHV16gEuJLmFaklGdTz8%3D'
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
az vm create -n $vmname -g $resourcegroup --attach-os-disk $destination --os-type linux --use-unmanaged-disk >/dev/null
echo VM created.

echo Finished!

exit 0