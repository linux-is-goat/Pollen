#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Run with sudo"
    exit 1
fi

OVERLAY="/tmp/overlay"
POLICY_DIR="$OVERLAY/etc/opt/chrome/policies/managed"

echo "Preparing overlay..."

# Clean start
rm -rf "$OVERLAY"
mkdir -p "$POLICY_DIR"

# Copy /etc WITHOUT breaking symlinks
cp -a /etc/. "$OVERLAY/etc"

# Write policy
cat > "$POLICY_DIR/policy.json" << 'EOF'
{
  "EditBookmarksEnabled": true,
  "DeveloperToolsAvailability": 1,
  "IncognitoModeAvailability": 0,
  "AllowDeletingBrowserHistory": true
}
EOF

sync

echo "Applying bind mount..."

# Small delay to avoid mid-write race
sleep 0.5

mount --bind "$OVERLAY/etc" /etc

echo "Done. (Flicker may still happen once)"
