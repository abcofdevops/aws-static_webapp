# AWS Static Web App Deployment Guide

A comprehensive, step-by-step guide to building and deploying a production-ready static website on AWS, progressing from a basic S3 setup to a fully secured, globally distributed web application.

## Overview

This guide walks you through building a static website that evolves from a simple S3 bucket to a sophisticated, enterprise-grade web application with global CDN, custom domain, SSL, and advanced security features.

## Prerequisites

- AWS CLI installed and configured with appropriate permissions
- A domain name (can be purchased through Route 53 or any registrar)
- Basic knowledge of HTML/CSS/JavaScript
- Understanding of command line operations
- Git and basic version control knowledge

## Architecture Evolution

The guide progresses through increasingly sophisticated architectures:

**Step 1:** `Internet → S3 Bucket`

**Step 2:** `Internet → CloudFront CDN → S3 Bucket`  

**Step 3:** `Internet → Route 53 DNS → CloudFront (Custom Domain + SSL) → S3 Bucket`

**Step 4:** `Internet → AWS WAF → Route 53 → CloudFront → S3 Bucket + CloudWatch Monitoring`

## Step-by-Step Guide

### [Step 1: Basic S3 Static Website Hosting](./01_basic-S3-website-hosting/)

**What you'll build:** A simple static website using only Amazon S3

**Key Features:**
- S3 bucket configured for static website hosting
- Public access for website files  
- Basic HTML/CSS/JS website accessible via S3 URL

**Architecture:** `Internet → S3 Bucket`

**Cost:** ~$0.03/month

**Time:** 15-30 minutes

**What you'll learn:**
- S3 bucket creation and configuration
- Static website hosting setup
- Bucket policies and public access
- Basic web hosting concepts

---
### [Step 2: Add CloudFront CDN and SSL](./02_cdn-and-ssl/)

**What you'll add:** Global CDN, HTTPS support, and enhanced performance

**Key Features:**
- CloudFront distribution for global content delivery
- HTTPS/SSL support with free AWS certificate
- Origin Access Identity (OAI) for security
- Improved caching and performance worldwide

**Architecture:** `Internet → CloudFront CDN → S3 Bucket`

**Cost:** ~$0.02-0.05/month (free tier covers most usage)

**Time:** 30-45 minutes (plus 15-20 minutes deployment time)

**What you'll learn:**
- CloudFront configuration and distribution
- SSL/TLS certificate management
- Origin Access Identity setup
- Global content delivery optimization
- Cache invalidation strategies

---

### [Step 3: Custom Domain with Route 53](./03_route-53/)

**What you'll add:** Professional custom domain name and DNS management

**Key Features:**
- Custom domain name (e.g., www.yourdomain.com)
- Route 53 hosted zone for DNS management
- Custom SSL certificate for your domain
- Professional website URL instead of CloudFront domain

**Architecture:** `Internet → Route 53 DNS → CloudFront (Custom Domain + SSL) → S3 Bucket`

**Cost:** ~$0.52/month (includes Route 53 hosted zone)

**Time:** 45-60 minutes (plus DNS propagation time)

**What you'll learn:**
- Domain registration and management
- DNS configuration with Route 53
- SSL certificate validation
- Domain-to-CloudFront integration
- Professional website deployment

---

### [Step 4: WAF Security and DDoS Protection](./04_waf/)

**What you'll add:** Enterprise-grade security, monitoring, and protection

**Key Features:**
- AWS WAF v2 with comprehensive security rules
- Rate limiting and DDoS protection  
- Bot detection and geographic restrictions
- Security monitoring and automated alerting
- CloudWatch dashboards and metrics

**Architecture:** `Internet → AWS WAF → Route 53 → CloudFront → S3 Bucket + CloudWatch`

**Cost:** ~$3-4/month (includes WAF and monitoring)

**Time:** 60-90 minutes

**What you'll learn:**
- Web Application Firewall configuration
- Security rule implementation
- Attack monitoring and response
- CloudWatch metrics and alerting
- Security best practices

---

##  Learning Path Recommendations

### Beginner Path
Start with **Step 1** to understand the basics, then progress through each step to build understanding gradually.

### Intermediate Path  
If you're familiar with AWS basics, you can start at **Step 2** and reference Step 1 as needed.

### Advanced Path
For experienced AWS users, review the architecture overview and jump to **Step 3** or **Step 4** directly.

## Cost Breakdown

| Step | Monthly Cost | What's Included |
|------|-------------|----------------|
| Step 1 | ~$0.03 | S3 storage only |
| Step 2 | ~$0.05 | S3 + CloudFront (free tier) |
| Step 3 | ~$0.52 | Above + Route 53 hosted zone |
| Step 4 | ~$3-4 | Above + WAF + monitoring |

*Costs are estimates for small websites with low-to-moderate traffic*

## Security Features by Step

- **Step 1:** Basic S3 bucket policies
- **Step 2:** Origin Access Identity, HTTPS encryption
- **Step 3:** Custom SSL certificates, DNS security
- **Step 4:** WAF protection, rate limiting, DDoS protection, security monitoring

## Global Performance Features

- **Step 1:** Single region (slow globally)
- **Step 2:** Global CloudFront edge locations
- **Step 3:** Custom domain with global CDN
- **Step 4:** Optimized security with global protection

## Monitoring and Observability

- **Step 1:** Basic S3 metrics
- **Step 2:** CloudFront metrics and logs
- **Step 3:** Route 53 health checks and DNS metrics  
- **Step 4:** Comprehensive security monitoring, CloudWatch dashboards, automated alerting

## Tools and Technologies Used

- **AWS Services:** S3, CloudFront, Route 53, Certificate Manager, WAF, CloudWatch, SNS
- **Infrastructure:** CloudFormation templates for reproducible deployments
- **CLI Tools:** AWS CLI for automation and management
- **Monitoring:** CloudWatch metrics, logs, and dashboards
- **Security:** WAF rules, SSL certificates, Origin Access Identity

## Important Notes

1. **Region Considerations:** SSL certificates for CloudFront must be created in `us-east-1`
2. **DNS Propagation:** Can take up to 48 hours for global propagation
3. **CloudFront Deployments:** Take 15-20 minutes to complete
4. **Cost Management:** Monitor usage and set up billing alerts
5. **Security:** Regularly review and update WAF rules and security policies

## Additional Resources

- **AWS Documentation:** [AWS Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html)
- **Best Practices:** [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- **Security Guide:** [AWS Security Best Practices](https://aws.amazon.com/security/security-learning/)

## Contributing

This guide is designed to be educational and production-ready. Each step includes:
- Complete working examples
- Troubleshooting guides
- Cost estimates
- Security best practices
- Cleanup instructions

## What You'll Achieve

By completing all steps, you'll have:

✅ A production-ready static website  
✅ Global content delivery network  
✅ Custom domain with SSL certificate  
✅ Enterprise-grade security protection  
✅ Comprehensive monitoring and alerting  
✅ Scalable, cost-effective hosting solution  
✅ Complete infrastructure automation  
✅ Industry-standard security practices  

**Ready to get started? Begin with [Step 1: Basic S3 Website Hosting](./01_basic-S3-website-hosting/)**