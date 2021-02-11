# 1. Export Groups and Users from Cognito

 1. Update config in `export-users-and-groups.sh`:

> userPoolId=eu-central-1_OLD 
> tempPassword=myPass

 2. Run: `export-users-and-groups.sh`. 
     Output : 3 files: 
>  groups_YYYYmmdd_HHMMSS.json  
>  users_YYYYmmdd_HHMMSS.json 
>  user-groups_YYYYmmdd_HHMMSS.json

# 2. Import Groups to Cognito

 1. Update config in `import-groups.sh`:
> oldUserPoolId=eu-central-1_OLD
> newUserPoolId=eu-central-1_NEW

 2. Run: `import-groups.sh groups_YYYYmmdd_HHMMSS.json`  

# 3. Import Users to Cognito

 1. Update config in `import-users.sh`:
> oldUserPoolId=eu-central-1_OLD
> newUserPoolId=eu-central-1_NEW

 2. Run: `import-users.sh users_YYYYmmdd_HHMMSS.json`  
 
# 4. Import User-Groups to Cognito

 1. Update config in `import-user-groups.sh`:
> oldUserPoolId=eu-central-1_OLD
> newUserPoolId=eu-central-1_NEW

 2. Run: `import-user-groups.sh groups_YYYYmmdd_HHMMSS.json`  