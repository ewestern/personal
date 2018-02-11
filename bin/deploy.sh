#!/bin/bash
set -eu
PROFILE=$1
BUCKET_NAME=www.peterfrance.net
DISTRIBUTION_ID=E3QZOPC89A1E21


hugo -v
aws s3 sync --profile $PROFILE --acl "public-read" --sse "AES256" public/ s3://$BUCKET_NAME 
aws cloudfront --profile $PROFILE create-invalidation --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
