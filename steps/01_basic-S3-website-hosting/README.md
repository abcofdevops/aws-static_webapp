# Step 1: Basic S3 Static Website Hosting

Deploy a simple static website using only Amazon S3 - the most basic and cost-effective approach.

## What You'll Build

- S3 bucket configured for static website hosting
- Public access for website files
- Simple HTML/CSS/JS website accessible via S3 website URL

## Prerequisites

- AWS CLI installed and configured
- Basic HTML website files ready to deploy
- AWS account with appropriate permissions

## Architecture

```
Internet → S3 Bucket (Static Website Hosting)
```

## Step-by-Step Instructions

### 1. Prepare Your Website Files

Create a simple website structure:
```
my-website/
├── index.html
├── error.html
├── css/
│   └── styles.css
├── js/
│   └── app.js
└── images/
    └── logo.png
```

### 2. Create S3 Bucket

Choose a globally unique bucket name (e.g., `my-static-website-bucket`):

```bash
# Replace 'my-static-website-bucket' with your unique bucket name
export BUCKET_NAME="my-static-website-bucket"
export AWS_REGION="us-east-1"

# Create the S3 bucket
aws s3 mb s3://$BUCKET_NAME --region $AWS_REGION
```

### 3. Configure Bucket for Static Website Hosting

```bash
# Enable static website hosting
aws s3 website s3://$BUCKET_NAME \
  --index-document index.html \
  --error-document error.html
```

### 4. Update Bucket Policy for Public Access

First, disable the block public access settings:

```bash
# Disable block public access (required for website hosting)
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```

Apply the bucket policy:

```bash
# Replace YOUR-BUCKET-NAME in the JSON file with your actual bucket name
sed "s/YOUR-BUCKET-NAME/$BUCKET_NAME/g" temp-policy.json > bucket-policy.json

# Apply the bucket policy
aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy file://bucket-policy.json
```

### 5. Upload Website Files

```bash
# Navigate to your website directory
cd my-website

# Upload all files to S3
aws s3 sync . s3://$BUCKET_NAME

# Verify upload
aws s3 ls s3://$BUCKET_NAME --recursive
```

### 6. Test Your Website

Get your website URL:

```bash
# Get the website endpoint
echo "Your website is available at: http://$BUCKET_NAME.s3-website-$AWS_REGION.amazonaws.com"
```

Visit the URL in your browser to see your live website!

## Updating Your Website

To update your website content:

```bash
# From your website directory
aws s3 sync . s3://$BUCKET_NAME --delete

# The --delete flag removes files from S3 that are no longer in your local directory
```

## Cost Estimation

**Monthly costs for a small website (< 1GB, < 10K requests):**
- S3 Standard Storage: ~$0.02
- S3 Requests: ~$0.01
- Data Transfer: First 1GB free
- **Total: ~$0.03/month**

## Limitations of This Setup

- No custom domain (you get an S3 website URL)
- No HTTPS/SSL support
- No global content delivery (slow for users far from your AWS region)
- No advanced caching or performance optimization
- Limited security features

## Cleanup

To remove all resources:

```bash
# Empty the bucket first
aws s3 rm s3://$BUCKET_NAME --recursive

# Delete the bucket
aws s3 rb s3://$BUCKET_NAME
```

## Next Steps

Once you have this basic setup working, you can move to **Step 2** which will add:
- CloudFront CDN for global content delivery
- HTTPS/SSL support
- Better performance and caching
- Custom domain support preparation

## Troubleshooting

**Common Issues:**

1. **403 Forbidden Error:**
   - Check bucket policy is correctly applied
   - Verify block public access settings are disabled
   - Ensure file permissions are correct

2. **404 Not Found:**
   - Verify index.html exists in bucket root
   - Check website hosting configuration

3. **Bucket name already exists:**
   - Choose a different, globally unique bucket name

**Useful Commands:**

```bash
# Check bucket website configuration
aws s3api get-bucket-website --bucket $BUCKET_NAME

# Check bucket policy
aws s3api get-bucket-policy --bucket $BUCKET_NAME

# List bucket contents
aws s3 ls s3://$BUCKET_NAME --recursive
```

---

**Congratulations!** You now have a basic static website running on AWS S3. This is the foundation that we'll build upon in the next steps.