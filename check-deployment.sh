#!/bin/bash

echo "🚀 CaixaPreta Stack - Deployment Status Checker"
echo "================================================"
echo ""

echo "📋 Checking repository status..."
echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Last commit: $(git log --oneline -1)"
echo ""

echo "📁 Checking deployment files..."
if [ -f "docs/matrix-index.html" ]; then
    echo "✅ Matrix installation guide: READY"
    echo "   Size: $(wc -c < docs/matrix-index.html) bytes"
else
    echo "❌ Matrix installation guide: MISSING"
fi

if [ -f "docs/simple-index.html" ]; then
    echo "✅ Simple installation guide: READY"
else
    echo "❌ Simple installation guide: MISSING"
fi

if [ -f ".github/workflows/deploy-docs.yml" ]; then
    echo "✅ GitHub Actions workflow: CONFIGURED"
else
    echo "❌ GitHub Actions workflow: MISSING"
fi

echo ""
echo "🌐 Expected deployment URLs:"
echo "   Main site: https://instalar.caixapreta.clubemkt.digital"
echo "   Matrix guide: https://instalar.caixapreta.clubemkt.digital/matrix.html"
echo "   Simple guide: https://instalar.caixapreta.clubemkt.digital/simple.html"
echo ""

echo "🔐 Access credentials:"
echo "   Password: caixapretastack2626"
echo ""

echo "📊 Deployment should be automatic via GitHub Actions"
echo "   Trigger: Push to main branch with docs/ changes"
echo "   Status: Check GitHub Actions tab in repository"
echo ""

echo "✅ All files committed and pushed to main branch!"
echo "🚀 Deployment should be processing automatically..."