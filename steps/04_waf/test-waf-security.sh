#!/bin/bash

DOMAIN="https://$DOMAIN_NAME"

echo " Testing WAF Security Rules for $DOMAIN"
echo "================================================"

# Test 1: Normal request (should succeed)
echo "Test 1: Normal request..."
response=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN")
if [ "$response" = "200" ]; then
    echo "✅ Normal request: PASSED (200)"
else
    echo "❌ Normal request: FAILED ($response)"
fi

# Test 2: SQL Injection attempt (should be blocked)
echo "Test 2: SQL Injection test..."
response=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN/?id=1' OR '1'='1")
if [ "$response" = "403" ]; then
    echo "✅ SQL Injection block: PASSED (403)"
else
    echo "❌ SQL Injection block: FAILED ($response)"
fi

# Test 3: XSS attempt (should be blocked)  
echo "Test 3: XSS test..."
response=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN/?search=<script>alert('xss')</script>")
if [ "$response" = "403" ]; then
    echo "✅ XSS block: PASSED (403)"
else
    echo "❌ XSS block: FAILED ($response)"
fi

# Test 4: Suspicious User-Agent (should be blocked)
echo "Test 4: Bad User-Agent test..."
response=$(curl -s -o /dev/null -w "%{http_code}" -H "User-Agent: BadBot" "$DOMAIN")
if [ "$response" = "403" ]; then
    echo "✅ Bad User-Agent block: PASSED (403)"
else
    echo "❌ Bad User-Agent block: FAILED ($response)"
fi

# Test 5: Rate limiting (requires multiple requests)
echo "Test 5: Rate limiting test (sending 10 rapid requests)..."
blocked_count=0
for i in {1..10}; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN/?test=$i")
    if [ "$response" = "403" ]; then
        ((blocked_count++))
    fi
    sleep 0.1
done

if [ $blocked_count -gt 0 ]; then
    echo "✅ Rate limiting: WORKING ($blocked_count requests blocked)"
else
    echo "⚠️ Rate limiting: NOT TRIGGERED (may need more aggressive testing)"
fi

echo "================================================"
echo "🔍 Check CloudWatch metrics and WAF logs for detailed analysis"