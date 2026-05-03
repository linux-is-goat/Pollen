#!/bin/bash

# Check for root
if [ $(id -u) -ne 0 ]; then
    echo "Please run this script as root. Use 'sudo -i'"
    exit 1
fi

echo "+##############################################+"
echo "| Welcome to Pollen!                           |"
echo "| The User Policy Editor                       |"
echo "| -------------------------------------------- |" 
echo "| Original Developers:                         |"
echo "| - OlyBaddie, Rafflesia, r58Playz             |"
echo "|                                              |"
echo "| Edited by: daydu3                            |"
echo "+##############################################+"
echo "May Ultrablue rest in peace, o7."
echo ""

sleep 1

# 1. Unlock and Force Read/Write
mount -o remount,rw / 2>/dev/null
mkdir -p /tmp/empty_dir

# 2. Generate your Mega JSON
cat <<EOF > /tmp/policy.json
{
  "URLBlocklist": [],
  "DeveloperToolsAvailability": 1,
  "IncognitoModeAvailability": 0,
  "ExtensionSettings": { "*": { "installation_mode": "allowed" } },
  "ArcPolicy": { "playStoreMode": "ENABLED" },
  "TaskManagerEndProcessEnabled": true,
  "CrostiniAllowed": true
}
EOF

# 3. KILL THE CLOUD VAULT (The v147 "Cloud" source)
# We wipe the cached cloud blobs and bind over the directory
rm -rf /var/lib/google/policies/* 2>/dev/null
mkdir -p /var/lib/google/policies
mount --bind /tmp/empty_dir /var/lib/google/policies

# 4. KILL THE USER CACHE (The most important part for v147)
# This searches your personal login folder for the hidden policy cache
echo "Blinding user-level caches..."
find /home/chronos/u-*/ -name "Policy" -type d | while read -r policy_dir; do
    mount --bind /tmp/empty_dir "$policy_dir"
done

# 5. INJECT PLATFORM POLICY
# Create paths and apply the local override
mkdir -p /etc/opt/chrome/policies/managed
touch /etc/opt/chrome/policies/managed/policy.json
mount --bind /tmp/policy.json /etc/opt/chrome/policies/managed/policy.json

# 6. REFRESH SESSION
echo "System blinded. Restarting UI..."
sleep 1
restart ui
