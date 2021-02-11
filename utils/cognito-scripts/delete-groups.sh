#!/bin/bash

if [ -z "$1" ]
    then
        echo "Delete all groups from UserPool. Usage:"
        echo "./delete-groups.sh userPoolId"
        exit 1
fi
userPoolId=$1

groupsFile=groupsToDelete-$userPoolId.tmp

aws cognito-idp list-groups --user-pool-id $userPoolId \
    | jq "[ .Groups[] | {UserPoolId, GroupName, Description, RoleArn} | with_entries( select( .value != null ) ) ]"  \
    > $groupsFile

groupsCount=$(cat $groupsFile | jq length)

echo "## Deleting $groupsCount groups"
for i in `seq 1 $groupsCount`
do
    groupName=$(cat $groupsFile | jq -r ".[$i - 1].GroupName")
    echo "Deleting group $groupName"
    aws cognito-idp delete-group --user-pool $userPoolId --group-name $groupName
done

rm $groupsFile

echo "## Deleted $groupsCount groups."