# Step 4: Add WAF Security and DDoS Protection

Build upon Step 3 by adding AWS WAF (Web Application Firewall) for advanced security, DDoS protection, rate limiting, and bot protection.

## What You'll Add

- AWS WAF v2 with security rules
- Rate limiting to prevent abuse
- Geographic restrictions (optional)
- Bot detection and blocking
- Security monitoring and alerting
- DDoS protection via AWS Shield Standard

## Prerequisites

- Completed Step 3 (Custom Domain setup)
- CloudFront distribution with custom domain active
- AWS CLI configured
- Basic understanding of web security concepts

## Architecture

```
Internet → AWS WAF (Security Layer) → CloudFront → S3 Bucket
           ↓
    CloudWatch (Monitoring & Alerts)
```

## Benefits Over Step 3

- **Advanced Security**: Protection against common web attacks
- **Rate Limiting**: Prevent abuse and DoS attacks
- **Bot Protection**: Block malicious bots while allowing good ones
- **Geographic Control**: Block/allow traffic from specific countries
- **Real-time Monitoring**: Track security events and attacks
- **Automated Response**: Block suspicious traffic automatically

## Step-by-Step Instructions

### 1. Setup Environment Variables

```bash
# Get values from previous steps
export DOMAIN_NAME="yourdomain.com"
export DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
  --stack-name static-website-cloudfront \
  --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
  --output text)

echo "Domain: $DOMAIN_NAME"
echo "CloudFront Distribution ID: $DISTRIBUTION_ID"
```

### 2. Create WAF Web ACL with CloudFormation

Create a comprehensive WAF configuration:

**waf-security-stack.yaml**

### 3. Deploy WAF Security Stack

```bash
# Deploy the WAF stack
aws cloudformation create-stack \
  --stack-name waf-security-${DOMAIN_NAME//./-} \
  --template-body file://waf-security-stack.yaml \
  --parameters \
    ParameterKey=CloudFrontDistributionId,ParameterValue=$DISTRIBUTION_ID \
    ParameterKey=DomainName,ParameterValue=$DOMAIN_NAME \
    ParameterKey=RateLimitPerIP,ParameterValue=2000

echo "Creating WAF security stack... This will take a few minutes."
aws cloudformation wait stack-create-complete --stack-name waf-security-${DOMAIN_NAME//./-}

# Get the Web ACL ARN
export WEB_ACL_ARN=$(aws cloudformation describe-stacks \
  --stack-name waf-security-${DOMAIN_NAME//./-} \
  --query 'Stacks[0].Outputs[?OutputKey==`WebACLArn`].OutputValue' \
  --output text)

echo "WAF Web ACL ARN: $WEB_ACL_ARN"
```

### 4. Associate WAF with CloudFront Distribution

Update your CloudFront distribution to use the WAF:

**cloudfront-with-waf.yaml**

### 5. Update CloudFront with WAF Association

```bash
# Get existing parameters
export BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name static-website-cloudfront \
  --query 'Stacks[0].Parameters[?ParameterKey==`BucketName`].ParameterValue' \
  --output text)

export OAI_ID=$(aws cloudformation describe-stacks \
  --stack-name static-website-cloudfront \
  --query 'Stacks[0].Parameters[?ParameterKey==`OriginAccessIdentityId`].ParameterValue' \
  --output text)

export SUBDOMAIN="www.$DOMAIN_NAME"
export CERTIFICATE_ARN=$(aws cloudformation describe-stacks \
  --stack-name static-website-cloudfront \
  --query 'Stacks[0].Parameters[?ParameterKey==`CertificateArn`].ParameterValue' \
  --output text)

# Update CloudFront stack to include WAF
aws cloudformation update-stack \
  --stack-name static-website-cloudfront \
  --template-body file://cloudfront-with-waf.yaml \
  --parameters \
    ParameterKey=BucketName,ParameterValue=$BUCKET_NAME \
    ParameterKey=OriginAccessIdentityId,ParameterValue=$OAI_ID \
    ParameterKey=DomainName,ParameterValue=$DOMAIN_NAME \
    ParameterKey=SubdomainName,ParameterValue=$SUBDOMAIN \
    ParameterKey=CertificateArn,ParameterValue=$CERTIFICATE_ARN \
    ParameterKey=WebACLArn,ParameterValue=$WEB_ACL_ARN

echo "Updating CloudFront with WAF protection... This will take 15-20 minutes."
aws cloudformation wait stack-update-complete --stack-name static-website-cloudfront
```

### 6. Setup Email Notifications for Security Alerts

```bash
# Get the SNS topic ARN
export SNS_TOPIC_ARN=$(aws cloudformation describe-stacks \
  --stack-name waf-security-${DOMAIN_NAME//./-} \
  --query 'Stacks[0].Outputs[?OutputKey==`SecurityAlertsTopicArn`].OutputValue' \
  --output text)

# Subscribe your email to security alerts
read -p "Enter your email for security alerts: " EMAIL_ADDRESS

aws sns subscribe \
  --topic-arn $SNS_TOPIC_ARN \
  --protocol email \
  --notification-endpoint $EMAIL_ADDRESS

echo "Check your email and confirm the subscription to receive security alerts."
```

### 7. Create Security Testing Scripts

Create scripts to test your WAF rules:

**test-waf-security.sh**

Make the script executable and run it:

```bash
chmod +x test-waf-security.sh
./test-waf-security.sh
```

### 8. Update Website Content with Security Information

**security-enhanced-index.html**

Upload the updated content:

```bash
# Upload the enhanced security content
aws s3 cp security-enhanced-index.html s3://$BUCKET_NAME/index.html

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
```

### 9. Monitor WAF Activity

View your WAF dashboard and metrics:

```bash
# Get dashboard URL
echo "🔍 View your security dashboard at:"
aws cloudformation describe-stacks \
  --stack-name waf-security-${DOMAIN_NAME//./-} \
  --query 'Stacks[0].Outputs[?OutputKey==`DashboardURL`].OutputValue' \
  --output text
```

Check WAF logs:

```bash
# View recent WAF logs
aws logs describe-log-streams \
  --log-group-name /aws/wafv2/$DOMAIN_NAME \
  --order-by LastEventTime \
  --descending

# Get recent log events
LATEST_STREAM=$(aws logs describe-log-streams \
  --log-group-name /aws/wafv2/$DOMAIN_NAME \
  --order-by LastEventTime \
  --descending \
  --max-items 1 \
  --query 'logStreams[0].logStreamName' \
  --output text)

if [ "$LATEST_STREAM" != "None" ]; then
    aws logs get-log-events \
      --log-group-name /aws/wafv2/$DOMAIN_NAME \
      --log-stream-name $LATEST_STREAM \
      --limit 10
fi
```

## Cost Estimation

**Monthly costs for a small website with WAF:**
- S3 Standard Storage: ~$0.02
- CloudFront: Free tier covers most small sites
- Route 53 Hosted Zone: $0.50
- **AWS WAF v2: $1.00 (base) + $0.60 per rule**
- CloudWatch Logs: ~$0.50
- **Total: ~$3-4/month**

## Advanced WAF Configuration

### Custom Rate Limiting Rules

Create more sophisticated rate limiting:

```yaml
# Custom rate limit for API endpoints
- Name: APIRateLimit
  Priority: 450
  Action:
    Block: {}
  Statement:
    RateBasedStatement:
      Limit: 100
      AggregateKeyType: IP
      ScopeDownStatement:
        ByteMatchStatement:
          FieldToMatch:
            UriPath: {}
          PositionalConstraint: STARTS_WITH
          SearchString: '/api/'
          TextTransformations:
            - Priority: 1
              Type: LOWERCASE
  VisibilityConfig:
    SampledRequestsEnabled: true
    CloudWatchMetricsEnabled: true
    MetricName: APIRateLimit
```

### Geographic Restrictions

```yaml
# Block specific countries
- Name: GeoBlock
  Priority: 850
  Action:
    Block: {}
  Statement:
    GeoMatchStatement:
      CountryCodes:
        - CN  # China
        - RU  # Russia
        - KP  # North Korea
  VisibilityConfig:
    SampledRequestsEnabled: true
    CloudWatchMetricsEnabled: true
    MetricName: GeoBlock
```

## Security Best Practices

1. **Regular Rule Updates**: Keep WAF rules updated with latest threat intelligence
2. **Log Analysis**: Regularly review WAF logs for patterns
3. **Rate Limit Tuning**: Adjust rate limits based on legitimate traffic patterns
4. **False Positive Monitoring**: Monitor for legitimate requests being blocked
5. **Security Testing**: Regularly test your security rules

## Next Steps

Once you have WAF security working, you can move to **Step 5** which will add:
- CI/CD pipeline with GitHub Actions or AWS CodePipeline
- Automated testing and deployment
- Multiple environment support (dev/staging/prod)
- Infrastructure as Code with full automation

## Troubleshooting

**Common Issues:**

1. **WAF blocking legitimate traffic:**
   ```bash
   # Check sampled requests in AWS Console
   aws wafv2 get-sampled-requests \
     --web-acl-arn $WEB_ACL_ARN \
     --rule-metric-name CoreRuleSet \
     --scope CLOUDFRONT \
     --time-window StartTime=$(date -d '1 hour ago' +%s),EndTime=$(date +%s) \
     --max-items 100
   ```

2. **CloudFront update fails:**
   - Ensure WAF is in the same region (us-east-1 for CloudFront)
   - Check that Web ACL exists and is accessible

3. **High WAF costs:**
   - Review rules and remove unused ones
   - Optimize rate limiting thresholds
   - Use AWS managed rules efficiently

**Useful Commands:**

```bash
# List all Web ACLs
aws wafv2 list-web-acls --scope CLOUDFRONT

# Get WAF metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/WAFV2 \
  --metric-name AllowedRequests \
  --dimensions Name=WebACL,Value=${DOMAIN_NAME}-security-acl Name=Region,Value=CloudFront \
  --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum
```

---

**Excellent Work!** Your website now has enterprise-grade security with AWS WAF, comprehensive monitoring, and automated threat protection. You're ready for Step 5 to add CI/CD automation!