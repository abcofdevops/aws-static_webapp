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