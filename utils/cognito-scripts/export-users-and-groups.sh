#!/bin/bash

# This script will export users and groups from Cognito $oldUserPoolId into:
# - groupss_$YYYYmmdd_HHMMSS.json
# - users_$YYYYmmdd_HHMMSS.json
# - users-groups_$YYYYmmdd_HHMMSS.json

# Set config: 
userPoolId=eu-central-1_LZmC5uTfD
tempPassword=Password0*             # Temp password for new users

date=$(date '+%Y%m%d_%H%M%S')
groupsFile=groups_$date.json
usersFile=users_$date.json
userGroupsFile=user-groups_$date.json

##################
# Group export
##################
echo -e "\nExporting  groups from $userPoolId..."

aws cognito-idp list-groups --user-pool-id $userPoolId \
    | jq "[ .Groups[] | {UserPoolId, GroupName, Description, RoleArn} | with_entries( select( .value != null ) ) ]"  \
    > $groupsFile

groupsCount=$(cat $groupsFile | jq length)
echo "Exported $groupsCount groups from $userPoolId"

##################
# Users export
##################
echo -e "\nExporting users from $userPoolId to $usersFile..."

aws cognito-idp list-users --user-pool-id $userPoolId \
    | jq "[ \
        .Users[] \
        | {UserPoolId: \"$userPoolId\", Username, Attributes, TemporaryPassword: \"$tempPassword\"} \
        | with_entries( select( .value != null ) ) \
        | with_entries(if .key == \"Attributes\" then .key = \"UserAttributes\" else . end) \
        | del(.UserAttributes[] | select(.Name == \"sub\")) \
        ]"  \
    > $usersFile

usersCount=$(cat $usersFile | jq length)
echo "Exported $usersCount users to $usersFile"

##################
# User-groups export
##################
echo -e "\nExporting groups users from $userPoolId to $userGroupsFile..."

echo "" > tmp-$userGroupsFile
for i in `seq 1 $usersCount`
do
    printf "."
    username=$(cat $usersFile | jq -r ".[$i - 1] | .Username")
    aws cognito-idp admin-list-groups-for-user --user-pool-id $userPoolId --username $username \
        | jq ".Groups[] | {UserPoolId:\"$userPoolId\", Username: \"$username\", GroupName}" \
        >> tmp-$userGroupsFile
done

cat tmp-$userGroupsFile | jq --slurp . > $userGroupsFile
rm tmp-$userGroupsFile

userGroupsCount=$(cat $userGroupsFile | jq --slurp length)
echo -e "\nExported $userGroupsCount user-groups to $userGroupsFile"