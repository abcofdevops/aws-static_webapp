# AWS Static WebApp
ABC of AWS Deployment | AWS Deployment 101 
Static Web App - AWS Deployment
A simple guide to deploy your static website on AWS with best practices.

## What You Need

- AWS Account
- Static website files (HTML, CSS, JS)
- Domain name (optional)

## AWS Services We'll Use

### Core Services
- **S3** - Stores your website files
- **CloudFront** - Makes your site load fast worldwide
- **Route 53** - Manages your custom domain (optional)

### Security & SSL
- **Certificate Manager** - Free SSL certificates
- **IAM** - Controls who can access what

## Quick Setup

### 1. Prepare Your Files

```bash
# Your project structure should look like:
my-website/
├── index.html
├── css/
├── js/
└── images/
```

### 2. Create S3 Bucket

```bash
# Install AWS CLI first
pip install awscli

# Configure AWS CLI
aws configure

# Create bucket (use a unique name)
aws s3 mb s3://my-website-bucket-123456

# Upload your files
aws s3 sync ./my-website s3://my-website-bucket-123456
```

### 3. Set Up Website Hosting

```bash
# Enable static website hosting
aws s3 website s3://my-website-bucket-123456 \
  --index-document index.html \
  --error-document error.html
```

Your website is now live at: `http://my-website-bucket-123456.s3-website-us-east-1.amazonaws.com`

## Better Setup (Recommended)

### Add CloudFront for Speed & SSL

1. Go to AWS Console → CloudFront
2. Click "Create Distribution"
3. Set Origin Domain to your S3 bucket
4. Set "Viewer Protocol Policy" to "Redirect HTTP to HTTPS"
5. Click "Create Distribution"

Wait 10-15 minutes for deployment. You'll get a URL like: `https://d1234567890123.cloudfront.net`

### Add Custom Domain

1. Go to AWS Console → Route 53
2. Create a hosted zone for your domain
3. Update your domain's nameservers
4. Go to Certificate Manager → Request Certificate for your domain
5. Add the certificate to your CloudFront distribution
6. Create an A record in Route 53 pointing to CloudFront

## Simple Infrastructure as Code

### Using AWS CDK (TypeScript)

```typescript
import * as cdk from 'aws-cdk-lib';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';
import * as origins from 'aws-cdk-lib/aws-cloudfront-origins';

export class SimpleWebsiteStack extends cdk.Stack {
  constructor(scope: any, id: string) {
    super(scope, id);

    // Create S3 bucket
    const bucket = new s3.Bucket(this, 'WebsiteBucket', {
      bucketName: 'my-simple-website-bucket',
      publicReadAccess: true,
      websiteIndexDocument: 'index.html',
    });

    // Create CloudFront distribution
    new cloudfront.Distribution(this, 'Distribution', {
      defaultRootObject: 'index.html',
      defaultBehavior: {
        origin: new origins.S3Origin(bucket),
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
      },
    });
  }
}
```

Deploy with:
```bash
npm install -g aws-cdk
cdk init app --language typescript
cdk deploy
```

## Simple CI/CD with GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy Website

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Upload to S3
        run: aws s3 sync . s3://my-website-bucket-123456 --delete
      
      - name: Clear CloudFront cache
        run: |
          aws cloudfront create-invalidation \
            --distribution-id E1234567890123 \
            --paths "/*"
```

## Cost Estimate

For a typical small website:
- **S3**: $1-5/month
- **CloudFront**: $1-10/month
- **Route 53**: $0.50/month per domain
- **Certificate Manager**: Free

Total: ~$5-20/month depending on traffic

## Common Commands

```bash
# Upload new files
aws s3 sync ./my-website s3://my-bucket-name --delete

# Clear CloudFront cache
aws cloudfront create-invalidation --distribution-id YOUR-ID --paths "/*"

# Check website status
curl -I https://your-website.com
```

## Troubleshooting

### Site not loading?
- Check S3 bucket policy allows public read
- Verify CloudFront distribution is deployed
- Check DNS settings if using custom domain

### SSL certificate issues?
- Certificate must be in us-east-1 region for CloudFront
- Wait for DNS validation to complete

### Files not updating?
- Clear CloudFront cache after uploading
- Check browser cache (hard refresh with Ctrl+F5)

## Security Basics

### S3 Bucket Policy (for public websites)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-website-bucket-123456/*"
    }
  ]
}
```

### IAM User Policy (for deployment)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "cloudfront:CreateInvalidation"
      ],
      "Resource": [
        "arn:aws:s3:::my-website-bucket-123456",
        "arn:aws:s3:::my-website-bucket-123456/*",
        "*"
      ]
    }
  ]
}
```

## That's It!

Your static website is now:
✅ Hosted on AWS  
✅ Fast worldwide (CloudFront CDN)  
✅ Secure (HTTPS)  
✅ Automatically deployed  

Need help? Check [AWS Documentation](https://docs.aws.amazon.com/s3/latest/userguide/WebsiteHosting.html) or AWS Support.