#!/bin/bash

# This script will import Cognito Users from input Json to Cognito userPool
# Set config: 
oldUserPoolId=eu-central-1_LZmC5uTfD
newUserPoolId=eu-central-1_nzmja4Jgb

if [ -z "$1" ]
    then
        echo "Input Json file is mandatory. Usage:"
        echo "./import-user-groups.sh my_data.json"
        exit 1
fi
userGroupsFile=$1

userGroupsCount=$(cat $userGroupsFile | jq length)

echo "## Associating $userGroupsCount groups to users in $newUserPoolId"
for i in `seq 1 $userGroupsCount`
do
    userGroup=$(cat $userGroupsFile | jq ".[$i - 1]")
    userGroup="${userGroup/$oldUserPoolId/$newUserPoolId}"
    aws cognito-idp admin-add-user-to-group --cli-input-json "$userGroup"
done

echo "## Associated $userGroupsCount groups to users in $newUserPoolId."