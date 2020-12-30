import json
import urllib
import boto3
import requests
import os
from botocore import UNSIGNED
from botocore.client import Config

accountId = os.environ['ACCOUNT_ID']
identityPoolId = os.environ['IDENTITY_POOL_ID']
userPoolId = os.environ['USER_POOL_ID']
sessionDuration = os.environ['SESSION_DURATION']

class BadRequestException(Exception):
    pass

class ForbiddenException(Exception):
    pass

def lambda_handler(event, context):
    
    global accountId, identityPoolId, userPoolId, sessionDuration
    
    try:
        
        destination = urllib.parse.quote_plus(getQueryParam(event, "destination"))
        idToken = getQueryParam(event, "id_token")
        
        cognitoClient = boto3.client('cognito-identity', config=Config(signature_version=UNSIGNED))
        
        # Get identity ID from Identity Pool
        
        userPoolRef = "cognito-idp.eu-central-1.amazonaws.com/" + userPoolId
        
        identityId = cognitoClient.get_id(
            AccountId = accountId,
            IdentityPoolId = identityPoolId,
            Logins = { userPoolRef : idToken }
        )["IdentityId"]
        
        # Get AWS creds from Identity Pool
        
        awsCreds = cognitoClient.get_credentials_for_identity(
            IdentityId = identityId,
            Logins = { userPoolRef : idToken }
        )["Credentials"]
        
        # Get SigninToken from federation endpoint
        
        sessionDict = { 
            "sessionId": awsCreds["AccessKeyId"],
            "sessionKey": awsCreds["SecretKey"],
            "sessionToken": awsCreds["SessionToken"]
        }

        params = {
            "Action": "getSigninToken",
            "SessionDuration": sessionDuration,
            "Session": json.dumps(sessionDict).replace(" ","")
        }
        
        r = requests.get('https://signin.aws.amazon.com/federation', params = params)
        
        if r.status_code != 200:
            raise ForbiddenException("Access denied. Unable to get federation signinToken from AWS creds.")
        
        signinToken = r.json()["SigninToken"]
        
        # Return redirection to AWS Console federated login page with signinToken
        
        location = "https://signin.aws.amazon.com/federation?Action=login&Destination={}&SigninToken={}".format(destination,signinToken)
        
        return { 
            "statusCode": 302,
            "headers": {
                "Location": location
            }
        }

    except BadRequestException as e:
        return getError(e, 400, str(e))
        
    except (cognitoClient.exceptions.NotAuthorizedException, ForbiddenException) as e:
        return getError(e, 403, str(e))
        
    except Exception as e:
        return getError(e, 500, "unexpected error")

def getQueryParam(event, key):
    value =  event["queryStringParameters"].get(key)
    if value is None:
        raise BadRequestException("Missing query param [{}].".format(key))
    return value
    
def getError(e, statusCode, msg):
    print(e)
    return {
        "isBase64Encoded": False,
        "statusCode": statusCode, 
        "body": json.dumps({"message": msg}),
        "headers": {"Content-Type": "application/json"}
    }