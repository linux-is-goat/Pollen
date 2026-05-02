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

mount -o remount,rw / 2>/dev/null || echo "Warning: RootFS is locked. Ensure 'debugd' helper was run."

# create the policy paths
PATHS=(
    "/etc/opt/chrome/policies/managed"
    "/etc/opt/chrome/policies/recommended"
    "/etc/chromium/policies"
    "/tmp/empty_dir"
)

for path in "${PATHS[@]}"; do
    mkdir -p "$path"
done

# json with policies we want to change
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
  "ExtensionSettings": { "*": { "installation_mode": "allowed" } },
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

# bind the thingies
TARGETS=(
    "/etc/opt/chrome/policies/managed/policy.json"
    "/etc/chromium/policies/managed/policy.json"
)

for target in "${TARGETS[@]}"; do
    touch "$target" 2>/dev/null
    mount --bind /tmp/policy.json "$target"
done


# Hide the folders to prevent them seeing
mount --bind /tmp/empty_dir /etc/opt/chrome/policies/recommended
mount --bind /tmp/empty_dir /etc/chromium/policies 2>/dev/null

echo "Pollen has been applied"
# 1. Kill the Cloud Policy Cache (The folder where 'Cloud' policies live)
# This forces Chrome to look at our 'Platform' files instead.
sudo rm -rf /var/lib/google/policies/*
sudo mkdir -p /var/lib/google/policies
sudo mount --bind /tmp/empty_dir /var/lib/google/policies

# 2. Block the specific 'Enrollment' policy check
sudo rm -rf /var/lib/whitelist/*
sudo mount --bind /tmp/empty_dir /var/lib/whitelist

# 3. Targeted Cloud policy paths for v129/v147
sudo mkdir -p /run/policy
sudo mount --bind /tmp/empty_dir /run/policy

restart ui
