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

