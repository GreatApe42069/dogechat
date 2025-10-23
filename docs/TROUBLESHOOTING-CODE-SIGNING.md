# Code Signing Troubleshooting Guide

## Problem Summary

The iOS build was failing with code signing errors for both the main app and Swift Package Manager (SPM) dependencies:

```
error: No Accounts: Add a new account in Accounts settings
error: No signing certificate "iOS Development" found
error: No profiles for 'chat.dogechat' were found
```

These errors occurred because:
1. A hardcoded Team ID (`L3N5LHJD5Y`) in `Configs/Release.xcconfig` didn't match the CI environment
2. The workflow had fallback values (`NOTSET`) that masked configuration errors
3. SPM packages (swift-secp256k1, Tor, BitLogger) inherit code signing settings from the main project

## Solution Implemented

### 1. Removed Hardcoded Team ID

**File: `Configs/Release.xcconfig`**

**Before:**
```
DEVELOPMENT_TEAM = L3N5LHJD5Y
```

**After:**
```
// DEVELOPMENT_TEAM should be set via:
// 1. Local.xcconfig for local development (gitignored)
// 2. Environment variable or command-line override for CI/CD
// 3. Xcode will prompt to select a team if not set
// DEVELOPMENT_TEAM = 
```

**Why:** Commented out the DEVELOPMENT_TEAM line allows it to be:
- Set via command-line in CI/CD: `DEVELOPMENT_TEAM="ABC123"`
- Set via `Local.xcconfig` for local development
- Inherited from Xcode preferences
- Prompted by Xcode if not set anywhere

### 2. Added Secret Validation

**File: `.github/workflows/ios-build.yml`**

Added a check to fail early if `APPLE_TEAM_ID` secret is not configured:

```bash
if [ -z "${{ secrets.APPLE_TEAM_ID }}" ]; then
  echo "ERROR: APPLE_TEAM_ID secret is not set"
  echo "Please add your Apple Developer Team ID as a repository secret"
  echo "Go to: Settings > Secrets and variables > Actions > New repository secret"
  exit 1
fi
```

**Why:** Provides clear error message instead of cryptic signing failures later.

### 3. Removed Fallback Values

**Before:**
```yaml
DEVELOPMENT_TEAM="${{ secrets.APPLE_TEAM_ID || 'NOTSET' }}"
```

**After:**
```yaml
DEVELOPMENT_TEAM="${{ secrets.APPLE_TEAM_ID }}"
```

**Why:** Fallback values like `NOTSET` mask configuration errors. Better to fail fast with a clear error.

## How Code Signing Works Now

### Configuration Precedence (highest to lowest)

1. **Command-line arguments** (CI/CD)
   ```bash
   xcodebuild ... DEVELOPMENT_TEAM="ABC123"
   ```

2. **Local.xcconfig** (local development)
   ```
   DEVELOPMENT_TEAM = ABC123
   ```

3. **Xcode Preferences** (GUI)
   - Xcode > Settings > Accounts

**Note on conflicts:** If DEVELOPMENT_TEAM is set in multiple places, Xcode uses the highest precedence source. Command-line parameters always override xcconfig files, which in turn override Xcode preferences. This ensures CI/CD builds can always override local development settings.

### For Different Environments

#### CI/CD (GitHub Actions)
1. Set `APPLE_TEAM_ID` in repository secrets
2. Workflow passes it via: `DEVELOPMENT_TEAM="${{ secrets.APPLE_TEAM_ID }}"`
3. Applied to ALL targets including SPM dependencies

#### Local Development
1. Copy `Configs/Local.xcconfig.example` to `Configs/Local.xcconfig`
2. Set your Team ID in `Local.xcconfig`:
   ```
   DEVELOPMENT_TEAM = YOUR_TEAM_ID
   ```
3. File is gitignored, won't be committed

#### Xcode GUI
1. If no Team ID is set, Xcode will:
   - Use the team from Xcode > Settings > Accounts (if only one)
   - Prompt you to select a team (if multiple)
   - Show an error (if no accounts configured)

## Swift Package Manager (SPM) Dependencies

### How SPM Dependencies Get Signed

When building for device (not simulator), Xcode requires ALL frameworks to be code signed, including SPM packages. The signing settings are inherited:

```
Main Project (dogechat.xcodeproj)
├── Build Settings
│   └── DEVELOPMENT_TEAM = [from xcconfig or command-line]
├── SPM Dependencies (automatically inherit)
│   ├── swift-secp256k1/libsecp256k1
│   ├── swift-secp256k1/P256K
│   ├── Tor/Tor
│   ├── Tor/TorC
│   └── BitLogger/BitLogger
```

### Why You Might See SPM Signing Errors

1. **No Team ID set**: SPM packages inherit empty DEVELOPMENT_TEAM
2. **Wrong Team ID**: SPM packages try to sign with invalid team
3. **No provisioning profiles**: Free accounts may have limited profile generation

### Solution
Ensure DEVELOPMENT_TEAM is properly set at the project level (via xcconfig, command-line, or Xcode), and it will automatically propagate to ALL SPM dependencies.

## Common Issues and Solutions

### Issue: "No signing certificate found"

**Cause:** No valid signing certificate for the specified Team ID

**Solution:**
1. Verify Team ID is correct (10 characters)
2. For free accounts: Xcode needs to be signed in with your Apple ID
3. For paid accounts: Download certificates from developer.apple.com
4. In CI/CD: Use `-allowProvisioningUpdates` flag (already in workflow)

### Issue: "No profiles found"

**Cause:** No provisioning profile for the bundle identifier

**Solution:**
1. For free accounts: Use `-allowProvisioningUpdates` (already in workflow)
2. For paid accounts: Create profiles at developer.apple.com
3. Ensure bundle ID matches your team's registered IDs

**⚠️ Warning:** `-allowProvisioningUpdates` may automatically create new provisioning profiles. If using a shared Apple Developer account, this could affect other team members' development environments. For team environments, consider manually managing profiles at developer.apple.com instead.

### Issue: SPM packages fail to sign

**Cause:** DEVELOPMENT_TEAM not propagating to packages

**Solution:**
1. Check that DEVELOPMENT_TEAM is set at xcodebuild command level
2. Verify no conflicting settings in Package.swift (there shouldn't be any)
3. Ensure building for device, not simulator (signing required for device)

### Issue: Works locally, fails in CI

**Cause:** Different team IDs or missing secrets

**Solution:**
1. Verify `APPLE_TEAM_ID` secret is set in GitHub
2. Check that secret name matches workflow: `secrets.APPLE_TEAM_ID`
3. Ensure Team ID has necessary permissions in CI environment

## Testing Your Setup

### Test Locally

```bash
# Navigate to the project root directory
cd ~/path/to/your/clone/of/dogechat

# Test with your Team ID
xcodebuild archive \
  -project dogechat.xcodeproj \
  -scheme "dogechat (iOS)" \
  -configuration Debug \
  -archivePath ./build/test.xcarchive \
  DEVELOPMENT_TEAM="YOUR_TEAM_ID"
```

### Test in CI

1. Push changes to trigger workflow
2. Check Actions tab for build logs
3. If fails, check for Team ID in build output
4. Verify all SPM packages inherit the Team ID

## References

- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [SPM in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)
