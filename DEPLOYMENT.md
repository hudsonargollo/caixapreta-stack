# Deployment Instructions

## CaixaPreta Stack Installation Guide

The password-protected installation guide is located in the `/docs` folder and is ready for deployment to Cloudflare Pages.

### Automatic Deployment

The repository includes a GitHub Actions workflow that automatically deploys the docs to Cloudflare Pages when changes are pushed to the `main` branch.

### Manual Deployment with Wrangler

1. **Install Wrangler CLI:**
```bash
npm install -g wrangler
```

2. **Login to Cloudflare:**
```bash
wrangler login
```

3. **Deploy the docs:**
```bash
cd docs
npm install
npm run build
wrangler pages deploy out --project-name=caixapreta-stack-docs
```

### Cloudflare Pages Configuration

- **Project Name:** `caixapreta-stack-docs`
- **Build Command:** `npm run build`
- **Build Output Directory:** `out`
- **Root Directory:** `docs`
- **Custom Domain:** `instalar.caixapreta.clubemkt.digital`

### Environment Variables Needed

For GitHub Actions deployment, add these secrets to your repository:

- `CLOUDFLARE_API_TOKEN` - Cloudflare API token with Pages:Edit permissions
- `CLOUDFLARE_ACCOUNT_ID` - Your Cloudflare account ID

### Access Information

- **URL:** https://instalar.caixapreta.clubemkt.digital
- **Password:** `caixapretastack2626`

The guide includes:
- Interactive installation steps
- Troubleshooting section
- Service configuration details
- Post-installation security checklist