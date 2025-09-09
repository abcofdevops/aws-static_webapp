# Add CloudFront CDN and SSL Support

Build upon Step 1 by adding Amazon CloudFront for global content delivery, HTTPS support, and better performance.

## What You'll Add

- CloudFront distribution for global CDN
- HTTPS/SSL support with free AWS certificate
- Origin Access Identity (OAI) for better security
- Improved caching and performance

## Prerequisites

- Completed Step 1 (Basic S3 Static Website)
- AWS CLI configured
- Your S3 bucket from Step 1 still active

## Architecture

```
Internet → CloudFront (Global CDN) → S3 Bucket (Origin)
```

## Benefits Over Step 1

- **Global Performance**: Content delivered from edge locations worldwide
- **HTTPS Support**: Free SSL certificate from AWS
- **Better Security**: Origin Access Identity restricts direct S3 access
- **Improved Caching**: Configurable cache behaviors
- **Custom Domains**: Prepare for your own domain name

## Step-by-Step Instructions

### 1. Secure Your S3 Bucket (Remove Public Access)

Since CloudFront will now serve your content, we need to secure the S3 bucket:

```bash
# Use your bucket name from Step 1
export BUCKET_NAME="your-bucket-name-from-step1"

# Re-enable block public access
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Remove the public bucket policy
aws s3api delete-bucket-policy --bucket $BUCKET_NAME

# Disable static website hosting (CloudFront will handle this)
aws s3api delete-bucket-website --bucket $BUCKET_NAME
```

### 2. Create Origin Access Identity (OAI)

```bash
# Create OAI for secure access to S3
aws cloudfront create-origin-access-identity \
  --origin-access-identity-config CallerReference="static-website-$(date +%s)",Comment="OAI for static website" \
  > oai-response.json

# Extract the OAI ID (you'll need this)
export OAI_ID=$(cat oai-response.json | grep '"Id"' | head -1 | sed 's/.*"Id": "//' | sed 's/".*//')
echo "OAI ID: $OAI_ID"
```

### 3. Create S3 Bucket Policy for CloudFront Access

Create a new bucket policy that only allows CloudFront access:

Apply the policy:

```bash
# Replace placeholders in the policy
sed "s/OAI-ID-PLACEHOLDER/$OAI_ID/g; s/BUCKET-NAME-PLACEHOLDER/$BUCKET_NAME/g"  temp-cf-policy.json > cloudfront-bucket-policy.json

# Apply the new bucket policy
aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy file://temp-cf-policy.json

# Clean up
rm temp-cf-policy.json
```

### 4. Create CloudFormation Template for CloudFront

Create a CloudFormation template for easy management:

**cloudfront-distribution.yaml**


### 5. Deploy CloudFront Distribution

```bash
# Deploy the CloudFormation stack
aws cloudformation create-stack \
  --stack-name static-website-cloudfront \
  --template-body file://cloudfront-distribution.yaml \
  --parameters ParameterKey=BucketName,ParameterValue=$BUCKET_NAME ParameterKey=OriginAccessIdentityId,ParameterValue=$OAI_ID

# Wait for stack creation (this can take 15-20 minutes)
echo "Creating CloudFront distribution... This will take 15-20 minutes."
aws cloudformation wait stack-create-complete --stack-name static-website-cloudfront

# Get the distribution domain name
export CLOUDFRONT_DOMAIN=$(aws cloudformation describe-stacks \
  --stack-name static-website-cloudfront \
  --query 'Stacks[0].Outputs[?OutputKey==`DistributionDomainName`].OutputValue' \
  --output text)

echo "CloudFront Distribution URL: https://$CLOUDFRONT_DOMAIN"
```

### 6. Update Your Website Files (Optional)

Add some improvements to showcase the new features:

**updated-index.html**

Upload the updated files:

```bash
# Upload updated files to S3
aws s3 sync ./my-website s3://$BUCKET_NAME

# Create a cache invalidation to see changes immediately
export DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
  --stack-name static-website-cloudfront \
  --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
  --output text)

aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
```

### 7. Test Your Enhanced Website

```bash
echo "Your website is now available at: https://$CLOUDFRONT_DOMAIN"
echo "Distribution ID: $DISTRIBUTION_ID"
```

**Test checklist:**
- [ ] Website loads over HTTPS
- [ ] All assets (CSS, JS, images) load correctly
- [ ] Error page works (try accessing /nonexistent-page)
- [ ] SSL certificate shows as valid in browser
- [ ] Performance improved (use browser dev tools to check loading times)

## Performance and Caching Configuration

### Cache Behaviors for Different File Types

You can optimize caching further by creating different cache behaviors:

**advanced-cache-config.json:**

## Cost Estimation

**Monthly costs for a small website (< 1GB, < 10K requests):**
- S3 Standard Storage: ~$0.02
- CloudFront Data Transfer: First 1TB free tier
- CloudFront Requests: First 10M requests free tier  
- **Total: ~$0.02-0.05/month** (mostly just S3 storage)

## Monitoring and Optimization

### View CloudFront Metrics

```bash
# Get basic metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/CloudFront \
  --metric-name Requests \
  --dimensions Name=DistributionId,Value=$DISTRIBUTION_ID \
  --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum
```

## Cleanup

To remove all resources:

```bash
# Delete CloudFormation stack (this will delete the CloudFront distribution)
aws cloudformation delete-stack --stack-name static-website-cloudfront

# Wait for deletion
aws cloudformation wait stack-delete-complete --stack-name static-website-cloudfront

# Delete OAI
aws cloudfront delete-origin-access-identity \
  --id $OAI_ID \
  --if-match $(aws cloudfront get-origin-access-identity --id $OAI_ID --query 'OriginAccessIdentity.ETag' --output text)

# Clean up S3 bucket (from Step 1 cleanup)
aws s3 rm s3://$BUCKET_NAME --recursive
aws s3 rb s3://$BUCKET_NAME
```

## Next Steps

Once you have CloudFront working, you can move to **Step 3** which will add:
- Custom domain name with Route 53
- Custom SSL certificate for your domain
- Better DNS management
- Professional website URL

## Troubleshooting

**Common Issues:**

1. **CloudFront distribution takes long to deploy:**
   - This is normal, distributions can take 15-20 minutes to deploy

2. **403 Forbidden errors:**
   - Check OAI configuration
   - Verify S3 bucket policy allows CloudFront access

3. **Changes not visible:**
   - CloudFront caches content; create an invalidation
   - Wait a few minutes for invalidation to complete

4. **SSL warnings:**
   - Using CloudFront default certificate will show warnings on custom domains
   - This is resolved in Step 3 with custom certificates

**Useful Commands:**

```bash
# Check distribution status
aws cloudfront get-distribution --id $DISTRIBUTION_ID

# List all distributions
aws cloudfront list-distributions

# Create invalidation for all files
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
```

---

**Congrats! Excellent Progress!** Your website now has global CDN, HTTPS support, and much better performance. You're ready for Step 3 to add a custom domain!