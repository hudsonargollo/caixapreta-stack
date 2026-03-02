#!/bin/bash

echo "🔑 Cloudflare API Token Test"
echo "============================"
echo ""

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "❌ CLOUDFLARE_API_TOKEN environment variable not set"
    echo "💡 Set it with: export CLOUDFLARE_API_TOKEN=your_token_here"
    exit 1
fi

echo "🔍 Testing API token..."
response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type: application/json")

if echo "$response" | grep -q '"success":true'; then
    echo "✅ API Token is valid!"
    echo "📋 Token details:"
    echo "$response" | jq '.result' 2>/dev/null || echo "$response"
else
    echo "❌ API Token is invalid or expired"
    echo "📋 Error details:"
    echo "$response" | jq '.errors' 2>/dev/null || echo "$response"
fi

echo ""
echo "🌐 Next steps:"
echo "1. Add CLOUDFLARE_API_TOKEN to GitHub repository secrets"
echo "2. Add CLOUDFLARE_ACCOUNT_ID to GitHub repository secrets"
echo "3. Create Cloudflare Pages project: caixapreta-stack-docs"
echo "4. Run GitHub Actions workflow"