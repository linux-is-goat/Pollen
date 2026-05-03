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

# Unlock filesystem
mount -o remount,rw / 2>/dev/null

# Create necessary directories (added the managed subfolders specifically)
mkdir -p /etc/opt/chrome/policies/managed
mkdir -p /etc/opt/chrome/policies/recommended
mkdir -p /etc/chromium/policies/managed
mkdir -p /var/lib/google/policies
mkdir -p /var/lib/enterprise
mkdir -p /var/lib/whitelist
mkdir -p /run/policy
mkdir -p /tmp/empty_dir

# 1. Generate the Policy JSON
cat <<EOF > /tmp/policy.json
{
  "URLBlocklist": [],
  "SystemFeaturesDisableList": [],
  "EditBookmarksEnabled": true,
  "BookmarkBarEnabled": true,
  "ChromeOsMultiProfileUserBehavior": "unrestricted",
  "DeveloperToolsAvailability": 1,
  "DefaultPopupsSetting": 1,
  "AllowDeletingBrowserHistory": true,
  "AllowDinosaurEasterEgg": true,
  "IncognitoModeAvailability": 0,
  "AllowScreenLock": true,
  "ExtensionAllowedTypes": ["*"],
  "ExtensionInstallAllowlist": ["*"],
  "ExtensionInstallBlocklist": [],
  "ExtensionInstallForcelist": [],
  "ExtensionSettings": {
    "*": {
      "installation_mode": "allowed"
    }
  },
  "PasswordManagerEnabled": true,
  "TaskManagerEndProcessEnabled": true,
  "SystemTerminalSshAllowed": true,
  "IsolatedAppsDeveloperModeAllowed": true,
  "ForceGoogleSafeSearch": false,
  "ForceYouTubeRestrict": 0,
  "EasyUnlockAllowed": true,
  "DisableSafeBrowsingProceedAnyway": false,
  "DeviceAllowNewUsers": true,
  "DevicePowerAdaptiveChargingEnabled": true,
  "DeviceGuestModeEnabled": true,
  "DeviceUnaffiliatedCrostiniAllowed": true,
  "VirtualMachinesAllowed": true,
  "CrostiniAllowed": true,
  "DefaultCookiesSetting": 1,
  "VmManagementCliAllowed": true,
  "WifiSyncAndroidAllowed": true,
  "DeveloperToolsDisabled": false,
  "DeviceBlockDevmode": false,
  "UserBorealisAllowed": true,
  "InstantTetheringAllowed": true,
  "NearbyShareAllowed": true,
  "PrintingEnabled": true,
  "SmartLockSigninAllowed": true,
  "PhoneHubAllowed": true,
  "LacrosAvailability": "user_choice",
  "ArcPolicy": {
    "playStoreMode": "ENABLED",
    "installType": "FORCE_INSTALLED",
    "playEmmApiInstallDisabled": false,
    "dpsInteractionsDisabled": false
  },
  "DnsOverHttpsMode": "automatic",
  "BrowserLabsEnabled": true,
  "ChromeOsReleaseChannelDelegated": true,
  "SafeSitesFilterBehavior": 0,
  "SafeBrowsingProtectionLevel": 0,
  "DownloadRestrictions": 0,
  "ProxyMode": "system",
  "ProxyServerMode": "system",
  "NetworkThrottlingEnabled": false,
  "NetworkPredictionOptions": 0
}
EOF

# 2. Block the Cloud/Enterprise Vaults
mount --bind /tmp/empty_dir /var/lib/google/policies
mount --bind /tmp/empty_dir /var/lib/enterprise 2>/dev/null
mount --bind /tmp/empty_dir /var/lib/whitelist 2>/dev/null
mount --bind /tmp/empty_dir /run/policy 2>/dev/null

# 3. Apply the "Anti-Force" trick on legacy paths
mount --bind /tmp/empty_dir /etc/opt/chrome/policies/recommended
mount --bind /tmp/empty_dir /etc/chromium/policies 2>/dev/null

# 4. Inject Custom Policies
# Explicitly creating the files before mounting
touch /etc/opt/chrome/policies/managed/policy.json 2>/dev/null
touch /etc/chromium/policies/managed/policy.json 2>/dev/null

mount --bind /tmp/policy.json /etc/opt/chrome/policies/managed/policy.json
mount --bind /tmp/policy.json /etc/chromium/policies/managed/policy.json

# 5. Clear User-level Policy Cache
find /home/chronos/user/ -name "Policy" -type d -exec mount --bind /tmp/empty_dir {} \; 2>/dev/null

echo ""
echo "Pollen has been successfully applied by daydu3!"
echo "Restarting UI..."
sleep 1
restart ui
