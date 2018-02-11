#!/bin/bash
set -eu
PROFILE=$1
BUCKET_NAME=timekeep.io-help
DISTRIBUTION_ID=E3NSDF40QZYKUC

hugo -v
aws s3 sync --profile $PROFILE --acl "public-read" --sse "AES256" public/ s3://$BUCKET_NAME 
aws cloudfront --profile $PROFILE create-invalidation --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
