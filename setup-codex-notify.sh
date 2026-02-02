#!/bin/bash
set -euo pipefail

# =============================================================================
# Setup script for Codex CLI macOS notifications
# Automatically configures sound + Notification Center alerts
# =============================================================================

SCRIPT_DIR="${HOME}/.codex"
NOTIFY_SCRIPT="${SCRIPT_DIR}/notify-macos.sh"
CONFIG_FILE="${HOME}/.codex/config.toml"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_info() { echo -e "${YELLOW}ℹ${NC} $1"; }

echo "========================================"
echo "Codex CLI macOS Notification Setup"
echo "========================================"
echo ""

# Step 1: Create ~/.codex directory
if [ ! -d "$SCRIPT_DIR" ]; then
    mkdir -p "$SCRIPT_DIR"
    print_success "Created directory: $SCRIPT_DIR"
else
    print_info "Directory already exists: $SCRIPT_DIR"
fi

# Step 2: Create the notify script
if [ -f "$NOTIFY_SCRIPT" ]; then
    print_info "Backing up existing notify script..."
    cp "$NOTIFY_SCRIPT" "${NOTIFY_SCRIPT}.backup.$(date +%Y%m%d%H%M%S)"
fi

cat > "$NOTIFY_SCRIPT" << 'EOF'
#!/bin/bash
set -euo pipefail

# Codex passes a JSON payload to the notify hook (often as the last argument).
# Keep it around if you want to log/parse later.
payload=""
if [ "$#" -gt 0 ]; then
  payload="${!#}"
fi

TITLE="Codex CLI"
BODY="Task finished"
SOUND_FILE="/System/Library/Sounds/Submarine.aiff"

# 1) Play a sound (reliable, non-blocking)
if command -v afplay >/dev/null 2>&1 && [ -f "$SOUND_FILE" ]; then
  afplay "$SOUND_FILE" >/dev/null 2>&1 &
fi

# 2) Show a macOS notification
/usr/bin/osascript -e "display notification \"$BODY\" with title \"$TITLE\"" >/dev/null 2>&1
EOF

chmod +x "$NOTIFY_SCRIPT"
print_success "Created notify script: $NOTIFY_SCRIPT"

# Step 3: Configure Codex CLI config.toml
if [ ! -f "$CONFIG_FILE" ]; then
    # Create new config file
    cat > "$CONFIG_FILE" << EOF
notify = ["/bin/bash", "$NOTIFY_SCRIPT"]
EOF
    print_success "Created new config file: $CONFIG_FILE"
else
    # Check if notify is already configured
    if grep -q '^notify\s*=' "$CONFIG_FILE" 2>/dev/null; then
        print_info "Notify hook already configured in $CONFIG_FILE"
        print_info "Current setting:"
        grep '^notify\s*=' "$CONFIG_FILE" || true
        echo ""
        read -p "Do you want to update it? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Backup original config
            cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)"
            # Remove existing notify line and add new one (handle both macOS and Linux sed)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' '/^notify\s*=/d' "$CONFIG_FILE"
            else
                sed -i '/^notify\s*=/d' "$CONFIG_FILE"
            fi
            echo "notify = [\"/bin/bash\", \"$NOTIFY_SCRIPT\"]" >> "$CONFIG_FILE"
            print_success "Updated notify hook in $CONFIG_FILE"
        else
            print_info "Skipped updating config.toml"
        fi
    else
        # Add notify line to existing config
        echo "" >> "$CONFIG_FILE"
        echo "notify = [\"/bin/bash\", \"$NOTIFY_SCRIPT\"]" >> "$CONFIG_FILE"
        print_success "Added notify hook to $CONFIG_FILE"
    fi
fi

echo ""
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
print_success "Notification script installed at: $NOTIFY_SCRIPT"
print_success "Config file updated at: $CONFIG_FILE"
echo ""
echo "To test the setup, run:"
echo "  $NOTIFY_SCRIPT '{}'"
echo ""
echo "Or run a short Codex task to see it in action."
echo ""

# Optional: Test the script
read -p "Would you like to test the notification now? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Sending test notification..."
    "$NOTIFY_SCRIPT" '{}'
    print_success "Test notification sent!"
fi
