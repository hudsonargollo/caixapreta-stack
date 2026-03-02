#!/bin/bash

# ==============================================================================
# DEPLOY TO CLOUDFLARE PAGES
# Deploy the enhanced CaixaPreta Stack installation guide
# ==============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}🚀 DEPLOYING CAIXAPRETA STACK INSTALLATION GUIDE${NC}"
echo "=================================================="
echo

echo -e "${BLUE}📋 Deployment Information:${NC}"
echo -e "  • Project: ${YELLOW}caixapreta-install-guide${NC}"
echo -e "  • URL: ${YELLOW}https://instalar.caixapreta.clubemkt.digital${NC}"
echo -e "  • Password: ${YELLOW}caixapretastack2626${NC}"
echo

echo -e "${GREEN}✅ Files committed to GitHub successfully!${NC}"
echo

echo -e "${BLUE}🚀 Deploying to Cloudflare Pages...${NC}"
echo

# Create deployment directory
mkdir -p deploy-temp
cp docs/clean-install.html deploy-temp/index.html
cp docs/matrix-index.html deploy-temp/matrix.html
mkdir -p deploy-temp/install
cp docs/clean-install.html deploy-temp/install/index.html

# Deploy using Wrangler
echo -e "${CYAN}📤 Uploading files...${NC}"
wrangler pages deploy deploy-temp --project-name=caixapreta-install-guide --commit-dirty=true

# Cleanup
rm -rf deploy-temp

echo
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}🌐 Your installation guide is now live at:${NC}"
echo -e "  • Main URL: ${YELLOW}https://instalar.caixapreta.clubemkt.digital${NC}"
echo -e "  • Password: ${YELLOW}caixapretastack2626${NC}"