#!/bin/bash

# This script will import Cognito Users from input Json to Cognito userPool
# Set config: 
oldUserPoolId=eu-central-1_LZmC5uTfD
newUserPoolId=eu-central-1_nzmja4Jgb

if [ -z "$1" ]
    then
        echo "Input Json file is mandatory. Usage:"
        echo "./import-users.sh my_data.json"
        exit 1
fi
usersFile=$1

usersCount=$(cat $usersFile | jq length)

echo "## Importing $usersCount users in $newUserPoolId"
for i in `seq 1 $usersCount`
do
    user=$(cat $usersFile | jq ".[$i - 1]")
    user="${user/$oldUserPoolId/$newUserPoolId}"    
    aws cognito-idp admin-create-user --cli-input-json "$user"
done

echo "## Imported $usersCount users in $newUserPoolId."