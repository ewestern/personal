set -eux
YOUR_DOMAIN="www.peterfrance.net"
REGION="us-east-1"
# Don't change these
BUCKET_NAME="${YOUR_DOMAIN}"
LOG_BUCKET_NAME="${BUCKET_NAME}-logs"
#aws s3 mb s3://$BUCKET_NAME --region $REGION
#aws s3 mb s3://$LOG_BUCKET_NAME --region $REGION

# Let AWS write the logs to this location
#aws s3api put-bucket-acl --bucket $LOG_BUCKET_NAME \
#--grant-write 'URI="http://acs.amazonaws.com/groups/s3/LogDelivery"' \
#--grant-read-acp 'URI="http://acs.amazonaws.com/groups/s3/LogDelivery"'

# Setup logging
LOG_POLICY="{\"LoggingEnabled\":{\"TargetBucket\":\"$LOG_BUCKET_NAME\",\"TargetPrefix\":\"$BUCKET_NAME\"}}"
#aws s3api put-bucket-logging --bucket $BUCKET_NAME --bucket-logging-status $LOG_POLICY
#aws s3api put-bucket-website --bucket $BUCKET_NAME --website-configuration file://policy.json

#SSL_ARN="arn:aws:acm:us-east-1:702853186114:certificate/dcfd8da1-7f4f-4bd3-becf-ae567983a3a5"
CALLER_REF="`date +%s`"

echo "{
    \"Comment\": \"$BUCKET_NAME Static Hosting\", 
    \"Logging\": {
        \"Bucket\": \"$LOG_BUCKET_NAME.s3.amazonaws.com\", 
        \"Prefix\": \"${BUCKET_NAME}-cf/\", 
        \"Enabled\": true,
        \"IncludeCookies\": false
    }, 
    \"Origins\": {
        \"Quantity\": 1,
        \"Items\": [
            {
                \"Id\":\"$BUCKET_NAME-origin\",
                \"OriginPath\": \"\", 
                \"CustomOriginConfig\": {
                    \"OriginProtocolPolicy\": \"http-only\", 
                    \"HTTPPort\": 80, 
                    \"OriginSslProtocols\": {
                        \"Quantity\": 3,
                        \"Items\": [
                            \"TLSv1\", 
                            \"TLSv1.1\", 
                            \"TLSv1.2\"
                        ]
                    }, 
                    \"HTTPSPort\": 443
                }, 
                \"DomainName\": \"$BUCKET_NAME.s3-website-$REGION.amazonaws.com\"
            }
        ]
    }, 
    \"DefaultRootObject\": \"index.html\", 
    \"PriceClass\": \"PriceClass_All\", 
    \"Enabled\": true, 
    \"CallerReference\": \"$CALLER_REF\",
    \"DefaultCacheBehavior\": {
        \"TargetOriginId\": \"$BUCKET_NAME-origin\",
        \"ViewerProtocolPolicy\": \"redirect-to-https\", 
        \"DefaultTTL\": 1800,
        \"AllowedMethods\": {
            \"Quantity\": 2,
            \"Items\": [
                \"HEAD\", 
                \"GET\"
            ], 
            \"CachedMethods\": {
                \"Quantity\": 2,
                \"Items\": [
                    \"HEAD\", 
                    \"GET\"
                ]
            }
        }, 
        \"MinTTL\": 0, 
        \"Compress\": true,
        \"ForwardedValues\": {
            \"Headers\": {
                \"Quantity\": 0
            }, 
            \"Cookies\": {
                \"Forward\": \"none\"
            }, 
            \"QueryString\": false
        },
        \"TrustedSigners\": {
            \"Enabled\": false, 
            \"Quantity\": 0
        }
    }, 
    \"CustomErrorResponses\": {
        \"Quantity\": 2,
        \"Items\": [
            {
                \"ErrorCode\": 403, 
                \"ResponsePagePath\": \"/404.html\", 
                \"ResponseCode\": \"404\",
                \"ErrorCachingMinTTL\": 300
            }, 
            {
                \"ErrorCode\": 404, 
                \"ResponsePagePath\": \"/404.html\", 
                \"ResponseCode\": \"404\",
                \"ErrorCachingMinTTL\": 300
            }
        ]
    }, 
    \"Aliases\": {
        \"Quantity\": 2,
        \"Items\": [
            \"$YOUR_DOMAIN\", 
            \"www.$YOUR_DOMAIN\"
        ]
    }
}" > distro_config.json

aws cloudfront create-distribution --distribution-config file://distro_config.json
