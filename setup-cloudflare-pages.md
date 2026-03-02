# 🌐 Cloudflare Pages Setup Guide

## Method 1: Via Cloudflare Dashboard (Recommended)

1. **Go to Cloudflare Pages**
   - Visit: https://dash.cloudflare.com/
   - Click "Pages" in the sidebar
   - Click "Create a project"

2. **Connect to Git**
   - Select "Connect to Git"
   - Choose "GitHub"
   - Select repository: `hudsonargollo/caixapreta-stack`

3. **Configure Build Settings**
   ```
   Project name: caixapreta-stack-docs
   Production branch: main
   Build command: cd docs && npm install --legacy-peer-deps && npm run build
   Build output directory: docs/out
   Root directory: /
   ```

4. **Environment Variables** (if needed)
   ```
   NODE_OPTIONS: --max-old-space-size=4096
   ```

5. **Custom Domain**
   - After deployment, go to "Custom domains"
   - Add: `instalar.caixapreta.clubemkt.digital`

## Method 2: Via GitHub Actions (After adding secrets)

Once you've added the API token and Account ID to GitHub secrets, I'll re-enable the Cloudflare workflow.

## Expected Result

Your Matrix installation guide will be available at:
- `https://instalar.caixapreta.clubemkt.digital`
- `https://caixapreta-stack-docs.pages.dev` (Cloudflare default)

## Troubleshooting

If you get 404 errors:
1. Check if the Pages project is created
2. Verify the build completed successfully
3. Ensure custom domain DNS is pointing to Cloudflare
4. Wait up to 24 hours for DNS propagation