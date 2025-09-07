# Static Web Application - AWS Production Deployment

A comprehensive guide for deploying a production-grade static web application on AWS with industry best practices, security, performance optimization, and monitoring.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [AWS Components](#aws-components)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Options](#deployment-options)
- [Infrastructure as Code](#infrastructure-as-code)
- [Security Configuration](#security-configuration)
- [Performance Optimization](#performance-optimization)
- [Monitoring & Logging](#monitoring--logging)
- [CI/CD Pipeline](#cicd-pipeline)
- [Cost Optimization](#cost-optimization)
- [Troubleshooting](#troubleshooting)

## AWS Components

### Core Services

#### Amazon S3 (Simple Storage Service)
- **Purpose**: Static asset hosting and storage
- **Features**: 
  - Website hosting capability
  - Versioning for rollback capability
  - Cross-region replication
  - Lifecycle policies for cost optimization
  - Server-side encryption

#### Amazon CloudFront (Content Delivery Network)
- **Purpose**: Global content distribution and caching
- **Features**:
  - Edge locations worldwide (400+ locations)
  - Custom SSL certificates
  - HTTP/2 and HTTP/3 support
  - Real-time logs and metrics
  - Origin failover
  - Lambda@Edge functions

#### Route 53 (DNS Service)
- **Purpose**: Domain name management and DNS routing
- **Features**:
  - Health checks and failover
  - Geographic routing
  - Weighted routing for A/B testing
  - Alias records for AWS resources
  - DNSSEC support

### Security Services

#### AWS WAF (Web Application Firewall)
- **Purpose**: Application-layer protection
- **Features**:
  - SQL injection protection
  - Cross-site scripting (XSS) prevention
  - Rate limiting
  - Geographic blocking
  - Custom security rules

#### AWS Certificate Manager (ACM)
- **Purpose**: SSL/TLS certificate management
- **Features**:
  - Free SSL certificates for AWS resources
  - Automatic renewal
  - Certificate validation
  - Integration with CloudFront and ALB

#### AWS Identity and Access Management (IAM)
- **Purpose**: Access control and permissions
- **Features**:
  - Role-based access control
  - Service-linked roles
  - Cross-account access
  - MFA enforcement

### Compute Services

#### Lambda@Edge
- **Purpose**: Server-side logic at CloudFront edge locations
- **Use Cases**:
  - URL rewrites and redirects
  - Authentication at the edge
  - A/B testing logic
  - SEO optimizations
  - Security headers injection

#### AWS Lambda
- **Purpose**: Serverless functions for API endpoints
- **Features**:
  - Auto-scaling
  - Pay-per-execution
  - Integration with API Gateway
  - Environment variables
  - Dead letter queues

### API and Integration Services

#### Amazon API Gateway
- **Purpose**: RESTful and WebSocket APIs
- **Features**:
  - Request/response transformation
  - Authentication and authorization
  - Rate limiting and throttling
  - API versioning
  - Request validation

#### AWS AppSync
- **Purpose**: GraphQL APIs with real-time features
- **Features**:
  - Real-time subscriptions
  - Offline synchronization
  - Multiple data sources
  - Built-in caching
  - Fine-grained access control

### Database Services

#### Amazon DynamoDB
- **Purpose**: NoSQL database for dynamic content
- **Features**:
  - Single-digit millisecond latency
  - Automatic scaling
  - Global tables
  - Point-in-time recovery
  - DynamoDB Accelerator (DAX) for caching

#### Amazon RDS
- **Purpose**: Relational database for complex queries
- **Options**: PostgreSQL, MySQL, MariaDB, Oracle, SQL Server
- **Features**:
  - Automated backups
  - Read replicas
  - Multi-AZ deployment
  - Performance Insights

### Monitoring and Analytics

#### Amazon CloudWatch
- **Purpose**: Monitoring, logging, and alerting
- **Features**:
  - Custom metrics and dashboards
  - Log aggregation and analysis
  - Automated scaling triggers
  - Anomaly detection
  - Composite alarms

#### AWS X-Ray
- **Purpose**: Distributed tracing and performance analysis
- **Features**:
  - Request tracing across services
  - Performance bottleneck identification
  - Error analysis
  - Service maps

#### Amazon Pinpoint
- **Purpose**: User analytics and engagement
- **Features**:
  - User behavior analytics
  - Push notifications
  - Email/SMS campaigns
  - A/B testing
  - Real-time event tracking

### Development and Deployment

#### AWS CodePipeline
- **Purpose**: Continuous integration and deployment
- **Features**:
  - Multi-stage pipelines
  - Integration with GitHub/CodeCommit
  - Automated testing
  - Manual approval gates
  - Cross-region deployment

#### AWS CodeBuild
- **Purpose**: Managed build service
- **Features**:
  - Scalable build environment
  - Custom build environments
  - Parallel builds
  - Build caching
  - Integration with testing frameworks

#### AWS CodeDeploy
- **Purpose**: Application deployment automation
- **Features**:
  - Blue/green deployments
  - Rolling deployments
  - Automatic rollback
  - Health checks during deployment

#### AWS CloudFormation
- **Purpose**: Infrastructure as Code
- **Features**:
  - Template-based resource provisioning
  - Stack management
  - Cross-stack references
  - Change sets for preview
  - Rollback capabilities

#### AWS CDK (Cloud Development Kit)
- **Purpose**: Define infrastructure using programming languages
- **Languages**: TypeScript, Python, Java, C#, Go
- **Features**:
  - Higher-level constructs
  - Type safety
  - IDE support
  - Reusable components

### Storage and Backup

#### Amazon S3 Glacier
- **Purpose**: Long-term archival and backup
- **Storage Classes**:
  - Glacier Instant Retrieval
  - Glacier Flexible Retrieval
  - Glacier Deep Archive

#### AWS Backup
- **Purpose**: Centralized backup management
- **Features**:
  - Cross-service backup
  - Automated backup schedules
  - Point-in-time recovery
  - Compliance reporting

### Additional Services

#### Amazon SES (Simple Email Service)
- **Purpose**: Transactional and marketing emails
- **Features**:
  - High deliverability
  - Bounce and complaint handling
  - Email analytics
  - Template management

#### Amazon SNS (Simple Notification Service)
- **Purpose**: Message publishing and notifications
- **Features**:
  - Fan-out messaging
  - Mobile push notifications
  - Email/SMS delivery
  - Message filtering

#### AWS Secrets Manager
- **Purpose**: Secure secret storage and rotation
- **Features**:
  - Automatic rotation
  - Fine-grained access control
  - Integration with AWS services
  - Cross-region replication

## Prerequisites

- AWS CLI v2.x installed and configured
- Node.js 18.x or later
- Docker (for local testing)
- Terraform 1.5+ or AWS CDK 2.x
- Domain name registered (optional but recommended)

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd static-app-aws
npm install
```

### 2. Build Application

```bash
# Development build
npm run build:dev

# Production build
npm run build:prod

# Build with environment-specific configs
npm run build -- --env production
```

### 3. Deploy to AWS

#### Option A: Using AWS CLI (Simple)

```bash
# Create S3 bucket
aws s3 mb s3://your-app-bucket-name --region us-east-1

# Enable static website hosting
aws s3 website s3://your-app-bucket-name \
  --index-document index.html \
  --error-document error.html

# Upload files
aws s3 sync ./dist s3://your-app-bucket-name --delete

# Create CloudFront distribution (see CloudFormation template)
```

#### Option B: Using Infrastructure as Code (Recommended)

```bash
# Using Terraform
cd infrastructure/terraform
terraform init
terraform plan -var="domain_name=example.com"
terraform apply

# Using AWS CDK
cd infrastructure/cdk
npm install
cdk bootstrap
cdk deploy --parameters domainName=example.com
```

## Deployment Options

### 1. Basic S3 Static Hosting

**Pros**: Simple, cost-effective for small sites
**Cons**: Limited features, no custom domain with HTTPS

```bash
aws s3 sync ./dist s3://bucket-name --delete
aws s3 website s3://bucket-name --index-document index.html
```

### 2. S3 + CloudFront (Recommended)

**Pros**: Global CDN, custom domains, SSL, better security
**Cons**: Slightly more complex setup

### 3. S3 + CloudFront + Route 53

**Pros**: Complete solution with custom domain and DNS management
**Cons**: Additional cost for Route 53

### 4. Multi-Environment Setup

```
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
└── infrastructure/
    ├── modules/
    └── environments/
```

## Infrastructure as Code

### Terraform Example

```hcl
# infrastructure/terraform/main.tf
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Static website distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
```

### AWS CDK Example (TypeScript)

```typescript
// infrastructure/cdk/lib/static-site-stack.ts
import * as cdk from 'aws-cdk-lib';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';
import * as origins from 'aws-cdk-lib/aws-cloudfront-origins';

export class StaticSiteStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // S3 Bucket
    const websiteBucket = new s3.Bucket(this, 'WebsiteBucket', {
      bucketName: `static-website-${this.account}-${this.region}`,
      publicReadAccess: false,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      versioned: true,
    });

    // Origin Access Identity
    const originAccessIdentity = new cloudfront.OriginAccessIdentity(
      this, 'OriginAccessIdentity'
    );

    websiteBucket.grantRead(originAccessIdentity);

    // CloudFront Distribution
    const distribution = new cloudfront.Distribution(this, 'Distribution', {
      defaultRootObject: 'index.html',
      defaultBehavior: {
        origin: new origins.S3Origin(websiteBucket, {
          originAccessIdentity,
        }),
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
        cachePolicy: cloudfront.CachePolicy.CACHING_OPTIMIZED,
      },
      errorResponses: [
        {
          httpStatus: 404,
          responseHttpStatus: 200,
          responsePagePath: '/index.html',
        },
      ],
    });

    // Outputs
    new cdk.CfnOutput(this, 'DistributionDomainName', {
      value: distribution.distributionDomainName,
    });
  }
}
```

## Security Configuration

### 1. S3 Bucket Security

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::your-bucket-name/*"
    }
  ]
}
```

### 2. Security Headers with Lambda@Edge

```javascript
// security-headers.js
exports.handler = (event, context, callback) => {
    const response = event.Records[0].cf.response;
    const headers = response.headers;

    headers['strict-transport-security'] = [{
        key: 'Strict-Transport-Security',
        value: 'max-age=31536000; includeSubdomains; preload'
    }];
    
    headers['content-security-policy'] = [{
        key: 'Content-Security-Policy',
        value: "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
    }];
    
    headers['x-content-type-options'] = [{
        key: 'X-Content-Type-Options',
        value: 'nosniff'
    }];
    
    headers['x-frame-options'] = [{
        key: 'X-Frame-Options',
        value: 'DENY'
    }];
    
    headers['referrer-policy'] = [{
        key: 'Referrer-Policy',
        value: 'strict-origin-when-cross-origin'
    }];

    callback(null, response);
};
```

### 3. WAF Configuration

```yaml
# WAF Rules
Resources:
  WebACL:
    Type: AWS::WAFv2::WebACL
    Properties:
      Name: StaticAppWebACL
      Scope: CLOUDFRONT
      DefaultAction:
        Allow: {}
      Rules:
        - Name: RateLimitRule
          Priority: 1
          Statement:
            RateBasedStatement:
              Limit: 10000
              AggregateKeyType: IP
          Action:
            Block: {}
          VisibilityConfig:
            SampledRequestsEnabled: true
            CloudWatchMetricsEnabled: true
            MetricName: RateLimitRule
```

## Performance Optimization

### 1. CloudFront Cache Behaviors

```javascript
// Different cache behaviors for different content types
const cacheBehaviors = [
  {
    pathPattern: "*.js",
    targetOriginId: "S3Origin",
    viewerProtocolPolicy: "redirect-to-https",
    cachePolicyId: "4135ea2d-6df8-44a3-9df3-4b5a84be39ad", // CachingOptimized
    compress: true
  },
  {
    pathPattern: "*.css",
    targetOriginId: "S3Origin",
    viewerProtocolPolicy: "redirect-to-https",
    cachePolicyId: "4135ea2d-6df8-44a3-9df3-4b5a84be39ad",
    compress: true
  },
  {
    pathPattern: "/api/*",
    targetOriginId: "APIGatewayOrigin",
    viewerProtocolPolicy: "https-only",
    cachePolicyId: "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  }
];
```

### 2. Asset Optimization

```json
// package.json build scripts
{
  "scripts": {
    "build:prod": "npm run clean && npm run build:assets && npm run build:app",
    "build:assets": "npm run compress:images && npm run minify:css && npm run bundle:js",
    "compress:images": "imagemin src/assets/images --out-dir=dist/assets/images",
    "minify:css": "cleancss -o dist/css/styles.min.css src/css/*.css",
    "bundle:js": "webpack --mode=production --config webpack.prod.js"
  }
}
```

### 3. Preloading and Resource Hints

```html
<!-- Resource hints for performance -->
<link rel="preload" href="/fonts/main.woff2" as="font" type="font/woff2" crossorigin>
<link rel="preload" href="/css/critical.css" as="style">
<link rel="preconnect" href="https://api.example.com">
<link rel="dns-prefetch" href="//analytics.example.com">
```

## Monitoring & Logging

### 1. CloudWatch Dashboard

```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/CloudFront", "Requests", "DistributionId", "E1234567890123"],
          [".", "BytesDownloaded", ".", "."],
          [".", "4xxErrorRate", ".", "."],
          [".", "5xxErrorRate", ".", "."]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "us-east-1",
        "title": "CloudFront Metrics"
      }
    }
  ]
}
```

### 2. Custom Metrics with Lambda@Edge

```javascript
const AWS = require('aws-sdk');
const cloudwatch = new AWS.CloudWatch({region: 'us-east-1'});

exports.handler = async (event, context) => {
    // Custom metric for page views
    await cloudwatch.putMetricData({
        Namespace: 'StaticApp/PageViews',
        MetricData: [
            {
                MetricName: 'PageView',
                Dimensions: [
                    {
                        Name: 'Page',
                        Value: event.Records[0].cf.request.uri
                    }
                ],
                Value: 1,
                Unit: 'Count'
            }
        ]
    }).promise();
};
```

### 3. Alerting Configuration

```yaml
PageViewAlert:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: High404ErrorRate
    AlarmDescription: Alert when 404 error rate is too high
    MetricName: 4xxErrorRate
    Namespace: AWS/CloudFront
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 5
    ComparisonOperator: GreaterThanThreshold
    AlarmActions:
      - !Ref SNSTopic
```

## CI/CD Pipeline

### 1. GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy Static App

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-east-1
  S3_BUCKET: your-app-bucket
  CLOUDFRONT_DISTRIBUTION_ID: E1234567890123

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Build application
      run: npm run build:prod
      
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}
    
    - name: Deploy to S3
      run: |
        aws s3 sync ./dist s3://${{ env.S3_BUCKET }} --delete --cache-control max-age=31536000
        aws s3 cp ./dist/index.html s3://${{ env.S3_BUCKET }}/index.html --cache-control max-age=0
    
    - name: Invalidate CloudFront
      run: |
        aws cloudfront create-invalidation \
          --distribution-id ${{ env.CLOUDFRONT_DISTRIBUTION_ID }} \
          --paths "/*"
```

### 2. AWS CodePipeline Configuration

```yaml
# buildspec.yml
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 18
  pre_build:
    commands:
      - echo Installing dependencies...
      - npm ci
  build:
    commands:
      - echo Building the application...
      - npm run test
      - npm run build:prod
  post_build:
    commands:
      - echo Build completed on `date`
artifacts:
  files:
    - '**/*'
  base-directory: dist
  name: static-app-build
```

## Cost Optimization

### 1. S3 Storage Classes

```javascript
// Lifecycle policy for cost optimization
const lifecyclePolicy = {
  Rules: [
    {
      Status: 'Enabled',
      Filter: {
        Prefix: 'logs/'
      },
      Transitions: [
        {
          Days: 30,
          StorageClass: 'STANDARD_IA'
        },
        {
          Days: 90,
          StorageClass: 'GLACIER'
        },
        {
          Days: 365,
          StorageClass: 'DEEP_ARCHIVE'
        }
      ]
    }
  ]
};
```

### 2. CloudFront Cost Optimization

```javascript
// Use appropriate price class
const distribution = new cloudfront.Distribution(this, 'Distribution', {
  priceClass: cloudfront.PriceClass.PRICE_CLASS_100, // US, Canada, Europe
  // vs PRICE_CLASS_ALL for global distribution
});
```

### 3. Monitoring Costs

```yaml
BudgetAlert:
  Type: AWS::Budgets::Budget
  Properties:
    Budget:
      BudgetName: StaticAppBudget
      BudgetLimit:
        Amount: 50
        Unit: USD
      TimeUnit: MONTHLY
      BudgetType: COST
    NotificationsWithSubscribers:
      - Notification:
          NotificationType: ACTUAL
          ComparisonOperator: GREATER_THAN
          Threshold: 80
        Subscribers:
          - SubscriptionType: EMAIL
            Address: admin@example.com
```

## Troubleshooting

### Common Issues

#### 1. CloudFront 403 Errors
```bash
# Check S3 bucket policy
aws s3api get-bucket-policy --bucket your-bucket-name

# Verify OAI permissions
aws cloudfront get-origin-access-identity --id E74FTE3AJFJ256A
```

#### 2. SSL Certificate Issues
```bash
# Check certificate status
aws acm list-certificates --region us-east-1

# Request new certificate
aws acm request-certificate \
  --domain-name example.com \
  --subject-alternative-names *.example.com \
  --validation-method DNS
```

#### 3. Route 53 DNS Issues
```bash
# Test DNS resolution
dig example.com
nslookup example.com

# Check hosted zone configuration
aws route53 list-hosted-zones
```

### Debug Commands

```bash
# Test CloudFront behavior
curl -I https://d1234567890123.cloudfront.net

# Check S3 website endpoint
curl -I http://bucket-name.s3-website-us-east-1.amazonaws.com

# View CloudWatch logs
aws logs describe-log-groups
aws logs get-log-events --log-group-name /aws/lambda/function-name
```

### Performance Testing

```bash
# Load testing with Artillery
npm install -g artillery
artillery quick --count 100 --num 10 https://your-site.com

# Lighthouse CI for performance monitoring
npm install -g @lhci/cli
lhci autorun --upload.target=temporary-public-storage
```

## Environment Variables

Create environment-specific configuration files:

```javascript
// config/production.js
module.exports = {
  API_BASE_URL: 'https://api.production.example.com',
  ANALYTICS_ID: 'GA-PROD-123456',
  CDN_URL: 'https://d1234567890123.cloudfront.net',
  ENABLE_DEBUG: false
};

// config/development.js
module.exports = {
  API_BASE_URL: 'https://api.dev.example.com',
  ANALYTICS_ID: 'GA-DEV-123456',
  CDN_URL: 'http://localhost:3000',
  ENABLE_DEBUG: true
};
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Documentation: [AWS Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- AWS Support: [Support Center](https://console.aws.amazon.com/support/)
- Community: [AWS Community Forums](https://forums.aws.amazon.com/)

---

**Note**: Replace placeholder values (bucket names, domain names, distribution IDs) with your actual values before deployment. Always review and test configurations in a development environment before applying to production.