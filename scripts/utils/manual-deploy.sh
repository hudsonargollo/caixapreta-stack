#!/bin/bash

echo "🚀 Manual Cloudflare Pages Deployment"
echo "====================================="
echo ""

# Check if required environment variables are set
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "❌ CLOUDFLARE_API_TOKEN not set"
    echo "💡 Set it with: export CLOUDFLARE_API_TOKEN=your_token_here"
    exit 1
fi

if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
    echo "❌ CLOUDFLARE_ACCOUNT_ID not set"
    echo "💡 Set it with: export CLOUDFLARE_ACCOUNT_ID=your_account_id_here"
    exit 1
fi

echo "🔍 Preparing Matrix installation guide for deployment..."

# Create deployment directory
mkdir -p manual-deploy
cd docs

# Copy Matrix guide as main page
cp clean-install.html ../manual-deploy/index.html
cp clean-install.html ../manual-deploy/clean.html

# Create install subdirectory
mkdir -p ../manual-deploy/install
cp clean-install.html ../manual-deploy/install/index.html

cd ..

echo "✅ Files prepared:"
ls -la manual-deploy/

echo ""
echo "🌐 Deploying to Cloudflare Pages..."

# Install wrangler if not available
if ! command -v wrangler &> /dev/null; then
    echo "📦 Installing Wrangler..."
    npm install -g wrangler
fi

# Deploy using wrangler
wrangler pages deploy manual-deploy \
    --project-name=caixapreta-install-guide

echo ""
echo "🎉 Deployment complete!"
echo "🌐 Your Matrix guide should be live at:"
echo "   https://instalar.caixapreta.clubemkt.digital"
echo "   https://caixapreta-install-guide.pages.dev"

# Cleanup
rm -rf manual-deploy