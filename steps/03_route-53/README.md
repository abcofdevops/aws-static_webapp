# Add Custom Domain with Route 53

Build upon Step 2 by adding a custom domain name using Route 53, custom SSL certificate, and professional DNS management.

## What You'll Add

- Custom domain name (e.g., www.yourdomain.com)
- Route 53 hosted zone for DNS management
- Custom SSL certificate from AWS Certificate Manager
- Professional website URL instead of CloudFront domain

## Prerequisites

- Completed Step 2 (CloudFront CDN setup)
- A domain name you own (can be purchased through Route 53 or any registrar)
- AWS CLI configured
- Your CloudFront distribution from Step 2 active

## Architecture

```
Internet → Route 53 (DNS) → CloudFront (Custom Domain + SSL) → S3 Bucket
```

## Benefits Over Step 2

- **Professional URL**: Use your own domain instead of CloudFront URL
- **Custom SSL Certificate**: Trusted certificate for your domain
- **DNS Control**: Full control over DNS records
- **Email Setup Ready**: Can add MX records for email
- **Subdomain Support**: Easy to add subdomains later

## Step-by-Step Instructions

### 1. Setup Domain Variables

```bash
# Replace with your actual domain name
export DOMAIN_NAME="yourdomain.com"
export SUBDOMAIN="www.$DOMAIN_NAME"

# Get your existing CloudFront distribution details
export DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
  --stack-name static-website-cloudfront \
  --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
  --output text)

echo "Domain: $DOMAIN_NAME"
echo "Subdomain: $SUBDOMAIN"
echo "Distribution ID: $DISTRIBUTION_ID"
```

### 2. Create Route 53 Hosted Zone

```bash
# Create hosted zone for your domain
aws route53 create-hosted-zone \
  --name $DOMAIN_NAME \
  --caller-reference "$(date +%s)" \
  --hosted-zone-config Comment="Hosted zone for static website" \
  > hosted-zone-response.json

# Get the hosted zone ID
export HOSTED_ZONE_ID=$(cat hosted-zone-response.json | jq -r '.HostedZone.Id' | sed 's|/hostedzone/||')

echo "Hosted Zone ID: $HOSTED_ZONE_ID"

# Get the name servers
aws route53 get-hosted-zone --id $HOSTED_ZONE_ID \
  --query 'DelegationSet.NameServers' \
  --output table
```

**Important:** Update your domain registrar's name servers with the ones shown above.

### 3. Request SSL Certificate

SSL certificates for CloudFront must be created in the `us-east-1` region:

```bash
# Request certificate for both domain and www subdomain
aws acm request-certificate \
  --domain-name $DOMAIN_NAME \
  --subject-alternative-names $SUBDOMAIN \
  --validation-method DNS \
  --region us-east-1 \
  > certificate-response.json

# Get certificate ARN
export CERTIFICATE_ARN=$(cat certificate-response.json | jq -r '.CertificateArn')

echo "Certificate ARN: $CERTIFICATE_ARN"
```

### 4. Validate SSL Certificate

```bash
# Get validation records needed
aws acm describe-certificate \
  --certificate-arn $CERTIFICATE_ARN \
  --region us-east-1 \
  --query 'Certificate.DomainValidationOptions' \
  > cert-validation.json

# Display validation records
echo "Add these DNS records to validate your certificate:"
cat cert-validation.json | jq -r '.[] | "Name: \(.ValidationDomain)\nType: CNAME\nValue: \(.ResourceRecord.Value)\n"'
```

Create DNS validation records:

**cert-validation-records.json**

**Automated validation record creation:**
```bash
# Extract validation info and create Route 53 records
python3 << 'EOF'
import json
import subprocess
import os

# Read validation data
with open('cert-validation.json', 'r') as f:
    validation_data = json.load(f)

# Create change batch
changes = []
for domain_validation in validation_data:
    if 'ResourceRecord' in domain_validation:
        change = {
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": domain_validation['ResourceRecord']['Name'],
                "Type": domain_validation['ResourceRecord']['Type'],
                "TTL": 300,
                "ResourceRecords": [
                    {"Value": domain_validation['ResourceRecord']['Value']}
                ]
            }
        }
        changes.append(change)

change_batch = {"Changes": changes}

# Write to file
with open('validation-changeset.json', 'w') as f:
    json.dump(change_batch, f, indent=2)

print("Validation records created in validation-changeset.json")
EOF

# Apply DNS changes
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file://validation-changeset.json
```

### 5. Wait for Certificate Validation

```bash
echo "Waiting for certificate validation... This may take a few minutes."

# Wait for certificate to be issued
aws acm wait certificate-validated \
  --certificate-arn $CERTIFICATE_ARN \
  --region us-east-1

echo "Certificate validated successfully!"
```

### 6. Update CloudFront Distribution with Custom Domain

Create an updated CloudFormation template:

**cloudfront-custom-domain.yaml**

### 7. Update CloudFront Distribution

```bash
# First, get the current values
export BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name static-website-cloudfront \
  --query 'Stacks[0].Parameters[?ParameterKey==`BucketName`].ParameterValue' \
  --output text)

export OAI_ID=$(aws cloudformation describe-stacks \
  --stack-name static-website-cloudfront \
  --query 'Stacks[0].Parameters[?ParameterKey==`OriginAccessIdentityId`].ParameterValue' \
  --output text)

# Update the CloudFormation stack with custom domain
aws cloudformation update-stack \
  --stack-name static-website-cloudfront \
  --template-body file://cloudfront-custom-domain.yaml \
  --parameters \
    ParameterKey=BucketName,ParameterValue=$BUCKET_NAME \
    ParameterKey=OriginAccessIdentityId,ParameterValue=$OAI_ID \
    ParameterKey=DomainName,ParameterValue=$DOMAIN_NAME \
    ParameterKey=SubdomainName,ParameterValue=$SUBDOMAIN \
    ParameterKey=CertificateArn,ParameterValue=$CERTIFICATE_ARN

echo "Updating CloudFront distribution... This will take 15-20 minutes."
aws cloudformation wait stack-update-complete --stack-name static-website-cloudfront

echo "CloudFront distribution updated with custom domain!"
```

### 8. Create DNS Records for Your Domain

Get the new CloudFront domain name:

```bash
export NEW_CLOUDFRONT_DOMAIN=$(aws cloudformation describe-stacks \
  --stack-name static-website-cloudfront \
  --query 'Stacks[0].Outputs[?OutputKey==`DistributionDomainName`].OutputValue' \
  --output text)

echo "CloudFront Domain: $NEW_CLOUDFRONT_DOMAIN"
```

Create DNS records:

**dns-records.json**

Apply DNS records:

```bash
# Replace placeholders and create DNS records
sed "s/DOMAIN_PLACEHOLDER/$DOMAIN_NAME/g; s/SUBDOMAIN_PLACEHOLDER/$SUBDOMAIN/g; s/CLOUDFRONT_DOMAIN_PLACEHOLDER/$NEW_CLOUDFRONT_DOMAIN/g" dns-records.json > final-dns-records.json

# Create the DNS records
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file://final-dns-records.json
```

### 9. Update Website Content

Update your website to reflect the custom domain:

**updated-index-custom-domain.html**

Upload the updated content:

```bash
# Update your local files first, then upload
aws s3 sync ./my-website s3://$BUCKET_NAME

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
```

### 10. Test Your Custom Domain

```bash
echo "🎉 Your website is now available at:"
echo "Primary: https://$DOMAIN_NAME"
echo "WWW: https://$SUBDOMAIN"
echo ""
echo "Both URLs will redirect to HTTPS automatically!"
```

**Test checklist:**
- [ ] Both domain and www.domain work
- [ ] HTTP redirects to HTTPS automatically
- [ ] SSL certificate shows as valid for your domain
- [ ] All assets load correctly
- [ ] DNS resolution works globally (test with `nslookup yourdomain.com`)

## Advanced DNS Configuration

### Add Additional Records

```bash
# Add MX record for email (example)
cat > email-records.json << 'EOF'
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "DOMAIN_PLACEHOLDER",
        "Type": "MX",
        "TTL": 300,
        "ResourceRecords": [
          {"Value": "10 mail.yourdomain.com"}
        ]
      }
    }
  ]
}
EOF

# Apply email records (uncomment when ready)
# sed "s/DOMAIN_PLACEHOLDER/$DOMAIN_NAME/g" email-records.json > final-email-records.json
# aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file://final-email-records.json
```

### Setup Subdomain Redirects

For redirecting non-www to www (or vice versa), you can create additional S3 buckets for redirects.

## Cost Estimation

**Monthly costs for a small website:**
- S3 Standard Storage: ~$0.02
- CloudFront Data Transfer: First 1TB free
- CloudFront Requests: First 10M requests free
- Route 53 Hosted Zone: $0.50/month
- SSL Certificate: Free through ACM
- **Total: ~$0.52/month**

## Monitoring Your Domain

### Check DNS Propagation

```bash
# Check DNS propagation
dig $DOMAIN_NAME
dig $SUBDOMAIN

# Check from different locations
nslookup $DOMAIN_NAME 8.8.8.8
nslookup $DOMAIN_NAME 1.1.1.1
```

### SSL Certificate Monitoring

```bash
# Check certificate expiration
aws acm describe-certificate \
  --certificate-arn $CERTIFICATE_ARN \
  --region us-east-1 \
  --query 'Certificate.NotAfter'
```

## Cleanup

To remove all resources:

```bash
# Delete DNS records first
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch '{
    "Changes": [
      {
        "Action": "DELETE",
        "ResourceRecordSet": {
          "Name": "'$DOMAIN_NAME'",
          "Type": "A",
          "AliasTarget": {
            "DNSName": "'$NEW_CLOUDFRONT_DOMAIN'",
            "EvaluateTargetHealth": false,
            "HostedZoneId": "Z2FDTNDATAQYW2"
          }
        }
      }
    ]
  }'

# Delete CloudFormation stack
aws cloudformation delete-stack --stack-name static-website-cloudfront
aws cloudformation wait stack-delete-complete --stack-name static-website-cloudfront

# Delete hosted zone
aws route53 delete-hosted-zone --id $HOSTED_ZONE_ID

# Delete certificate
aws acm delete-certificate --certificate-arn $CERTIFICATE_ARN --region us-east-1

# Clean up S3 bucket
aws s3 rm s3://$BUCKET_NAME --recursive
aws s3 rb s3://$BUCKET_NAME
```

## Next Steps

Once you have your custom domain working, you can move to **Step 4** which will add:
- Web Application Firewall (WAF) for security
- DDoS protection
- Rate limiting and bot protection
- Geographic restrictions
- Advanced security monitoring

## Troubleshooting

**Common Issues:**

1. **Certificate validation fails:**
   - Ensure DNS records for validation are correctly added
   - Wait up to 30 minutes for DNS propagation

2. **Domain doesn't resolve:**
   - Check name servers at your registrar match Route 53
   - DNS propagation can take up to 48 hours globally

3. **SSL certificate errors:**
   - Ensure certificate includes both domain and www subdomain
   - Certificate must be in us-east-1 region for CloudFront

4. **CloudFront update takes long:**
   - Distribution updates can take 15-30 minutes
   - Check AWS Console for deployment status

**Useful Commands:**

```bash
# Test SSL certificate
openssl s_client -connect $DOMAIN_NAME:443 -servername $DOMAIN_NAME

# Check DNS resolution
host $DOMAIN_NAME
host $SUBDOMAIN

# Check CloudFront distribution status
aws cloudfront get-distribution --id $DISTRIBUTION_ID --query 'Distribution.Status'
```

---

**Congratulations!** You now have a professional static website with your own custom domain, SSL certificate, and global CDN. Your website is production-ready and performs excellently worldwide!