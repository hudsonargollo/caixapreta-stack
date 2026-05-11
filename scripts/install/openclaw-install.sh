#!/bin/bash

# ==============================================================================
# OPENCLAW INSTALLER
# Installs OpenClaw AI assistant with popular skills from awesome-openclaw-skills
# https://github.com/openclaw/openclaw
# https://github.com/VoltAgent/awesome-openclaw-skills
# Author: Hudson Argollo / CaixaPreta
# System: macOS, Linux (Ubuntu/Debian), Windows (WSL2)
# ==============================================================================

set -e

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

log_info()    { echo -e "${CYAN}${BOLD}[INFO]${NC} ${CYAN}$1${NC}"; }
log_success() { echo -e "${GREEN}${BOLD}[OK]${NC} ${GREEN}$1${NC}"; }
log_error()   { echo -e "${RED}${BOLD}[ERROR]${NC} ${RED}$1${NC}"; }
log_step()    { echo -e "\n${PURPLE}${BOLD}>>> $1${NC}"; }
log_warn()    { echo -e "${YELLOW}${BOLD}[WARN]${NC} ${YELLOW}$1${NC}"; }

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "${CYAN}${BOLD}"
echo "  ___                  ____ _               "
echo " / _ \ _ __   ___ _ _ / ___| | __ ___      __"
echo "| | | | '_ \ / _ \ '_ \ |   | |/ _\` \ \ /\ / /"
echo "| |_| | |_) |  __/ | | | |___| | (_| |\ V  V / "
echo " \___/| .__/ \___|_| |_|\____|_|\__,_| \_/\_/  "
echo "      |_|                                       "
echo -e "${NC}"
echo -e "${BOLD}OpenClaw Installer — CaixaPreta Edition${NC}"
echo -e "Your personal AI assistant. Any OS. Any Platform. 🦞"
echo ""

# ── System detection ──────────────────────────────────────────────────────────
log_step "Detecting System"

OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    log_info "macOS detected"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    log_info "Linux detected"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
    log_warn "Windows detected — WSL2 strongly recommended"
else
    log_warn "Unknown OS: $OSTYPE — proceeding anyway"
fi

# ── Node.js check ─────────────────────────────────────────────────────────────
log_step "Checking Node.js"

NODE_OK=false
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version | sed 's/v//')
    NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 22 ]; then
        log_success "Node.js $NODE_VERSION found (required: 22+)"
        NODE_OK=true
    else
        log_warn "Node.js $NODE_VERSION found but 22+ required"
    fi
fi

if [ "$NODE_OK" = false ]; then
    log_info "Installing Node.js 24..."
    if [ "$OS" = "macos" ]; then
        if command -v brew >/dev/null 2>&1; then
            brew install node@24
            export PATH="/opt/homebrew/opt/node@24/bin:$PATH"
        else
            log_error "Homebrew not found. Install from https://brew.sh then re-run."
            exit 1
        fi
    elif [ "$OS" = "linux" ]; then
        curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
        apt-get install -y nodejs
    else
        log_error "Please install Node.js 24 manually from https://nodejs.org then re-run."
        exit 1
    fi
    log_success "Node.js installed"
fi

# ── npm/pnpm check ────────────────────────────────────────────────────────────
log_step "Checking Package Manager"

PKG_MGR="npm"
if command -v pnpm >/dev/null 2>&1; then
    PKG_MGR="pnpm"
    log_info "pnpm found — using pnpm"
elif command -v npm >/dev/null 2>&1; then
    log_info "npm found — using npm"
else
    log_error "No package manager found. Install npm or pnpm."
    exit 1
fi

# ── Install OpenClaw ──────────────────────────────────────────────────────────
log_step "Installing OpenClaw"

if command -v openclaw >/dev/null 2>&1; then
    CURRENT_VERSION=$(openclaw --version 2>/dev/null || echo "unknown")
    log_info "OpenClaw already installed ($CURRENT_VERSION) — updating..."
    $PKG_MGR install -g openclaw@latest
else
    log_info "Installing openclaw globally..."
    $PKG_MGR install -g openclaw@latest
fi

# Verify
if ! command -v openclaw >/dev/null 2>&1; then
    log_error "OpenClaw installation failed. Check npm/pnpm output above."
    exit 1
fi

OPENCLAW_VERSION=$(openclaw --version 2>/dev/null || echo "installed")
log_success "OpenClaw $OPENCLAW_VERSION installed"

# ── Configuration ─────────────────────────────────────────────────────────────
log_step "Configuration"

echo ""
echo "OpenClaw needs an AI model provider to work."
echo "Supported: OpenAI, Anthropic, Google, Mistral, and 20+ others."
echo ""
echo "Options:"
echo "  1) OpenAI API key (recommended)"
echo "  2) Anthropic API key (Claude)"
echo "  3) Skip — configure manually later"
echo ""
read -p "Choose [1/2/3]: " MODEL_CHOICE

MODEL_PROVIDER=""
API_KEY=""

case "$MODEL_CHOICE" in
    1)
        MODEL_PROVIDER="openai/gpt-4o"
        read -p "Enter your OpenAI API key: " API_KEY
        ;;
    2)
        MODEL_PROVIDER="anthropic/claude-opus-4-5"
        read -p "Enter your Anthropic API key: " API_KEY
        ;;
    3)
        log_info "Skipping model config — run 'openclaw onboard' to configure later"
        ;;
    *)
        log_warn "Invalid choice — skipping model config"
        ;;
esac

# Write minimal config if API key provided
if [ -n "$API_KEY" ] && [ -n "$MODEL_PROVIDER" ]; then
    OPENCLAW_DIR="$HOME/.openclaw"
    mkdir -p "$OPENCLAW_DIR"

    PROVIDER=$(echo "$MODEL_PROVIDER" | cut -d/ -f1)

    cat > "$OPENCLAW_DIR/openclaw.json" << EOF
{
  "agent": {
    "model": "$MODEL_PROVIDER"
  },
  "auth": {
    "$PROVIDER": {
      "apiKey": "$API_KEY"
    }
  }
}
EOF
    log_success "Config written to $OPENCLAW_DIR/openclaw.json"
fi

# ── Install Skills ─────────────────────────────────────────────────────────────
log_step "Installing Skills"

echo ""
echo "Which skill packs would you like to install?"
echo ""
echo "  1) 🤖 Automation & n8n integration"
echo "  2) 💬 WhatsApp & messaging"
echo "  3) 🔍 Search & research"
echo "  4) 📊 DevOps & cloud"
echo "  5) 🌐 Browser & web automation"
echo "  6) All of the above (recommended)"
echo "  7) Skip — install skills manually later"
echo ""
read -p "Choose [1-7]: " SKILL_CHOICE

SKILLS_DIR="$HOME/.openclaw/workspace/skills"
mkdir -p "$SKILLS_DIR"

install_skill() {
    local skill_name="$1"
    local skill_url="$2"
    log_info "Installing skill: $skill_name"
    if command -v clawhub >/dev/null 2>&1; then
        clawhub install "$skill_name" 2>/dev/null || log_warn "clawhub install failed for $skill_name — skipping"
    else
        # Manual install via git clone into skills dir
        local skill_dir="$SKILLS_DIR/$skill_name"
        if [ -d "$skill_dir" ]; then
            log_info "Skill $skill_name already exists — skipping"
        else
            git clone --depth=1 "$skill_url" "$skill_dir" 2>/dev/null || log_warn "Could not clone $skill_name — skipping"
        fi
    fi
}

install_skill_pack() {
    local pack="$1"
    case "$pack" in
        automation)
            log_info "Installing automation skills..."
            install_skill "n8n" "https://github.com/openclaw/skills/tree/main/skills/n8n"
            install_skill "n8n-workflow-automation" "https://github.com/openclaw/skills/tree/main/skills/n8n-workflow-automation"
            install_skill "agent-task-manager" "https://github.com/openclaw/skills/tree/main/skills/agent-task-manager"
            install_skill "cron-scheduling" "https://github.com/openclaw/skills/tree/main/skills/cron-scheduling"
            ;;
        whatsapp)
            log_info "Installing WhatsApp/messaging skills..."
            install_skill "agent-mail" "https://github.com/openclaw/skills/tree/main/skills/agent-mail"
            install_skill "agentmesh" "https://github.com/openclaw/skills/tree/main/skills/agentmesh"
            install_skill "elevenlabs-tts" "https://github.com/openclaw/skills/tree/main/skills/elevenlabs-tts"
            ;;
        search)
            log_info "Installing search & research skills..."
            install_skill "openclaw-free-web-search" "https://github.com/openclaw/skills/tree/main/skills/openclaw-free-web-search"
            install_skill "academic-research" "https://github.com/openclaw/skills/tree/main/skills/academic-research"
            install_skill "agent-deep-research" "https://github.com/openclaw/skills/tree/main/skills/agent-deep-research"
            ;;
        devops)
            log_info "Installing DevOps & cloud skills..."
            install_skill "agentic-devops" "https://github.com/openclaw/skills/tree/main/skills/agentic-devops"
            install_skill "docker" "https://github.com/openclaw/skills/tree/main/skills/moltbot-docker"
            install_skill "nordvpn" "https://github.com/openclaw/skills/tree/main/skills/nordvpn"
            ;;
        browser)
            log_info "Installing browser & automation skills..."
            install_skill "agent-browser" "https://github.com/openclaw/skills/tree/main/skills/agent-browser"
            install_skill "browser-automation" "https://github.com/openclaw/skills/tree/main/skills/agent-browser"
            ;;
    esac
}

case "$SKILL_CHOICE" in
    1) install_skill_pack automation ;;
    2) install_skill_pack whatsapp ;;
    3) install_skill_pack search ;;
    4) install_skill_pack devops ;;
    5) install_skill_pack browser ;;
    6)
        install_skill_pack automation
        install_skill_pack whatsapp
        install_skill_pack search
        install_skill_pack devops
        install_skill_pack browser
        ;;
    7) log_info "Skipping skills — install later with: clawhub install <skill-name>" ;;
    *) log_warn "Invalid choice — skipping skills" ;;
esac

# ── Run onboard ───────────────────────────────────────────────────────────────
log_step "Setup"

echo ""
echo "Would you like to run the interactive OpenClaw onboard wizard?"
echo "This sets up channels (WhatsApp, Telegram, Slack, etc.) and the gateway daemon."
echo ""
read -p "Run onboard? [y/N]: " RUN_ONBOARD

if [[ "$RUN_ONBOARD" =~ ^[Yy]$ ]]; then
    log_info "Starting OpenClaw onboard..."
    openclaw onboard --install-daemon
else
    log_info "Skipping onboard — run manually with: openclaw onboard --install-daemon"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}=========================================="
echo "  OpenClaw installed successfully! 🦞"
echo -e "==========================================${NC}"
echo ""
echo -e "${BOLD}Quick commands:${NC}"
echo "  openclaw onboard --install-daemon   # Full setup wizard"
echo "  openclaw gateway --port 18789       # Start gateway"
echo "  openclaw agent --message 'Hello'    # Talk to assistant"
echo "  openclaw doctor                     # Check health"
echo ""
echo -e "${BOLD}Skills directory:${NC} $SKILLS_DIR"
echo -e "${BOLD}Config:${NC} $HOME/.openclaw/openclaw.json"
echo ""
echo -e "${BOLD}Resources:${NC}"
echo "  Docs:   https://openclaw.ai"
echo "  Skills: https://clawhub.ai"
echo "  Awesome skills: https://github.com/VoltAgent/awesome-openclaw-skills"
echo ""
echo -e "${CYAN}Part of the CaixaPreta ecosystem — https://caixapreta.clubemkt.digital/${NC}"
