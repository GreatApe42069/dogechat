# iOS Build Setup Guide

## Current Status: Free Apple Developer Account Build

The iOS build workflow (`.github/workflows/ios-build.yml`) is configured to build a **code-signed** iOS app using a **free Apple Developer account**. This allows installation on physical devices for testing without requiring a paid ($99/year) developer account.

### What the Current Build Does

1. **Builds with code signing**: Uses `CODE_SIGNING_ALLOWED=YES` and automatic code signing
2. **Uses your Team ID**: References `APPLE_TEAM_ID` from GitHub secrets
3. **Proper IPA export**: Uses `xcodebuild -exportArchive` with development distribution method
4. **Produces signed IPA**: The output `dogechat.ipa` is code-signed and can be installed on physical devices
5. **Automatic re-signing**: Runs every 6 days to re-sign the app before the 7-day expiration
6. **Permanent download link**: Automatically uploads to GitHub Release for easy access

### Current Capabilities

- ✅ Can be installed on physical iOS devices (via Xcode, Apple Configurator, or other installation methods)
- ✅ Properly code-signed with your free Apple Developer account
- ✅ Works for development and testing on your own devices
- ✅ Automatically re-signs every 6 days (no manual intervention needed)
- ✅ Always up to date with the latest code changes
- ✅ Permanent download link via GitHub Release (no need to browse Actions tab)
- ❌ Cannot be distributed via App Store (requires paid account)
- ❌ Cannot be distributed via TestFlight (requires paid account)

## Setup Instructions

### Step 1: Get a Free Apple Developer Account

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Sign up using any Apple ID (this is **FREE** - no $99 fee required)
3. Accept the developer agreement

### Step 2: Get Your Team ID

**Option A: Using Xcode**
1. Open Xcode
2. Go to Xcode → Preferences (or Settings) → Accounts
3. Sign in with your Apple ID
4. Select your account and click "View Details" or "Manage Certificates"
5. Your Team ID is shown next to your account name (10 character string)

**Option B: Using Apple Developer Website**
1. Log in to [developer.apple.com/account](https://developer.apple.com/account)
2. Go to the Membership section
3. Copy your Team ID (format: `XXXXXXXXXX`, 10 characters)

### Step 3: Add Team ID to GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `APPLE_TEAM_ID`
5. Value: Your 10-character Team ID (e.g., `AB12CD34EF`)
6. Click **Add secret**

### Step 4: Run the Build

**Option A: Automatic (Recommended)**
The workflow runs automatically every 6 days at 00:00 UTC to re-sign the app before the 7-day expiration. Just set up the `APPLE_TEAM_ID` secret and the workflow will handle the rest.

**Option B: Manual**
1. Go to the **Actions** tab in your GitHub repository
2. Select **"Build iOS App"** workflow
3. Click **"Run workflow"** button
4. Select the branch and click **"Run workflow"**
5. Wait for the build to complete

### Step 5: Download the IPA

**Permanent Download Link (Easiest):**

The latest signed IPA is always available at this permanent link:
**https://github.com/GreatApe42069/dogechat/releases/tag/ios-latest**

Simply visit the link and download `dogechat.ipa` - it's automatically updated every 6 days with a fresh signature.

**Alternative - From Actions Tab:**

1. Go to the **Actions** tab in your GitHub repository
2. Click on the latest successful workflow run
3. Scroll down to the **Artifacts** section
4. Download the `dogechat-ios-app` artifact containing `dogechat.ipa`

### Step 6: Install on Your Device

**Option A: Using Xcode**
1. Connect your iOS device to your Mac
2. Open Xcode and go to Window → Devices and Simulators
3. Select your device
4. Drag and drop the `dogechat.ipa` file to the "Installed Apps" section

**Option B: Using Apple Configurator**
1. Download and install [Apple Configurator](https://apps.apple.com/app/apple-configurator/id1037126344)
2. Connect your iOS device
3. Double-click the device in Apple Configurator
4. Click "Add" → "Apps" and select the `dogechat.ipa` file

**Option C: Using Command Line**
```bash
# Install using ios-deploy
npm install -g ios-deploy
ios-deploy --bundle dogechat.ipa
```


## Upgrading to Paid Apple Developer Account

If you upgrade to a paid Apple Developer account ($99/year), you can:

- ✅ Distribute via App Store
- ✅ Distribute via TestFlight for beta testing
- ✅ Apps don't expire after 7 days
- ✅ Support for more advanced features

### Changes Needed for Paid Account

The workflow is already configured correctly! Just update your `APPLE_TEAM_ID` secret with your new paid account Team ID. You can optionally:

1. Change the export method to `app-store` for App Store distribution:
   ```yaml
   <key>method</key>
   <string>app-store</string>
   ```

2. Or use `ad-hoc` for distributing to up to 100 registered devices:
   ```yaml
   <key>method</key>
   <string>ad-hoc</string>
   ```

## Distribution Methods

Once code signing is properly configured, you can choose different export methods:

- **development**: For installing on registered development devices
- **ad-hoc**: For distributing to up to 100 registered devices
- **app-store**: For submitting to the App Store
- **enterprise**: For enterprise distribution (requires Enterprise account)

## Testing the Build

After making changes, you can test the workflow:

1. Go to Actions tab in GitHub
2. Select "Build iOS App" workflow
3. Click "Run workflow"
4. Monitor the build progress

## Troubleshooting

### "No signing certificate found" or "No profiles found"

This is normal when using a free Apple Developer account with GitHub Actions. The workflow uses `-allowProvisioningUpdates` which tells Xcode to automatically create the necessary provisioning profiles. However, this may not work in CI/CD environments.

**Workaround**: If the build fails with signing errors, you may need to:
1. Build locally in Xcode first to generate the provisioning profile
2. Export the provisioning profile and add it to the GitHub runner (advanced)
3. Or continue using the unsigned build approach for CI/CD and sign locally

### "APPLE_TEAM_ID secret not set"

Make sure you've added the `APPLE_TEAM_ID` secret to your repository:
1. Go to Settings → Secrets and variables → Actions
2. Verify `APPLE_TEAM_ID` exists with your 10-character Team ID

### "App expires after 7 days"

This limitation is **automatically handled** by the workflow! The build runs every 6 days automatically, ensuring a fresh signed IPA is always available before expiration.

**What happens:**
1. The workflow runs automatically every 6 days via GitHub Actions scheduled trigger
2. A new signed IPA is built and uploaded as an artifact
3. Download the latest artifact from the Actions tab to get the fresh signature
4. The 7-day timer resets with each new build

**Manual options if needed:**
1. The workflow already runs automatically every 6 days (no action needed)
2. You can also manually trigger the workflow anytime from the Actions tab
3. Upgrade to a paid account ($99/year) for apps that don't expire
2. Upgrade to a paid account ($99/year) for apps that don't expire
3. Use tools like [AltStore](https://altstore.io/) for automatic re-signing on your device

### "Code signing is required"
- Remove `CODE_SIGNING_ALLOWED=NO`
- Set up proper provisioning profiles

### "Profile doesn't match"
- Regenerate provisioning profiles in Apple Developer Portal
- Download and install profiles in Xcode

## Additional Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [App Distribution Guide](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
