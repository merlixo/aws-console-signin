#!/bin/bash

DIR=$(dirname "$0")

# Build lambda-aws-signin 
cd $DIR

docker run -v $PWD:/code python:3.8-slim pip install -t /code/package -r /code/requirements.txt

rm -f function.zip
cd package; zip -r ../function.zip *; cd -
zip -g function.zip lambda_function.py