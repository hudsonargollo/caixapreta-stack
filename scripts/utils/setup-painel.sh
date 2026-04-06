#!/bin/bash

# Setup Admin Painel
# This script downloads and sets up the admin painel files

set -e

PAINEL_DIR="/data/painel"
REPO_URL="https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/docs"

echo "Setting up Admin Painel..."

# Create directory
mkdir -p "$PAINEL_DIR"

# Download files
echo "Downloading painel files..."
wget -q "$REPO_URL/painel-admin.html" -O "$PAINEL_DIR/painel-admin.html"
wget -q "$REPO_URL/painel-server.js" -O "$PAINEL_DIR/painel-server.js"
wget -q "$REPO_URL/design-tokens.css" -O "$PAINEL_DIR/design-tokens.css"

# Set permissions
chmod 644 "$PAINEL_DIR"/*.html
chmod 644 "$PAINEL_DIR"/*.js
chmod 644 "$PAINEL_DIR"/*.css
chown -R 1000:1000 "$PAINEL_DIR"

echo "✓ Admin Painel setup complete"
echo "Access at: https://your-domain/painel"
