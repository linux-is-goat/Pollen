#!/bin/bash

if [ $(id -u) -ne 0 ]; then
    echo "Please run this script as root. You can do so by using 'sudo su'."
    exit
fi

echo "+##############################################+"
echo "| Welcome to Pollen!                           |"
echo "| The User Policy Editor                       |"
echo "| -------------------------------------------- |"
echo "| Original Developers:                         |"
echo "| - OlyB, Rafflesia, r58Playz                  |"
echo "|                                              |"
echo "| Edited by: daydu3                            |"
echo "+##############################################+"
echo "May Ultrablue rest in peace, o7."

sleep 1

# 1. Setup the local directory
mkdir -p /etc/opt/chrome/policies/managed

# 2. Generate the optimized policy JSON
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

# 3. Apply the policy specifically to avoid the /etc crash loop
touch /etc/opt/chrome/policies/managed/policy.json
mount --bind /tmp/policy.json /etc/opt/chrome/policies/managed/policy.json

echo ""
echo "Pollen has been successfully applied!"
echo "Restarting UI to finalize changes..."
sleep 1
restart ui
