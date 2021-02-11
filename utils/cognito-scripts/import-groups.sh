#!/bin/bash

# This script will import Cognito Groups from input Json to Cognito userPool
# Set config: 
oldUserPoolId=eu-central-1_LZmC5uTfD
newUserPoolId=eu-central-1_nzmja4Jgb

if [ -z "$1" ]
    then
        echo "Input Json file is mandatory. Usage:"
        echo "./import-groups.sh my_data.json"
        exit 1
fi
inputFile=$1

groupsCount=$(cat $inputFile | jq length)

echo "## Importing $groupsCount groups in $newUserPoolId"
for i in `seq 1 $groupsCount`
do
    group=$(cat $inputFile | jq ".[$i - 1]")
    group="${group/$oldUserPoolId/$newUserPoolId}"    
    echo $group
    aws cognito-idp create-group --cli-input-json "$group"
done

echo "## Imported $groupsCount groups in $newUserPoolId."