# iOS Build Setup Guide

## Current Status: Temporary Placeholder Build

The current iOS build workflow (`.github/workflows/ios-build.yml`) is configured to build an **unsigned** iOS app without requiring an Apple Developer account. This is a temporary solution that produces an IPA file that cannot be distributed through the App Store or TestFlight.

### What the Current Build Does

1. **Builds without code signing**: Uses `CODE_SIGNING_ALLOWED=NO` to skip the signing process
2. **Uses placeholder team**: Sets `DEVELOPMENT_TEAM=PLACEHOLDER` to embed minimal team metadata
3. **Manual IPA packaging**: Directly packages the `.app` bundle into an IPA instead of using `xcodebuild -exportArchive`
4. **Produces unsigned IPA**: The output `dogechat-unsigned.ipa` is not signed and cannot be installed on physical devices

### Limitations

- ❌ Cannot be distributed via App Store
- ❌ Cannot be distributed via TestFlight
- ❌ Cannot be installed on physical iOS devices (requires jailbreak or development provisioning)
- ✅ Can be used to verify the build process completes
- ✅ Can be used for CI/CD pipeline testing
- ✅ Archive contains the compiled app for inspection

## Setting Up Proper Code Signing

Once you have an Apple Developer account, follow these steps to enable proper code signing:

### Step 1: Get Your Apple Developer Team ID

1. Log in to [Apple Developer Portal](https://developer.apple.com)
2. Go to Membership section
3. Copy your Team ID (format: `XXXXXXXXXX`, 10 characters)

### Step 2: Update the Workflow

Edit `.github/workflows/ios-build.yml`:

1. **Replace the placeholder team** (line ~45):
   ```yaml
   # Change from:
   DEVELOPMENT_TEAM=PLACEHOLDER
   
   # To:
   DEVELOPMENT_TEAM=YOUR_TEAM_ID
   ```

2. **Enable code signing** (lines ~43-44):
   ```yaml
   # Remove these two lines:
   CODE_SIGN_IDENTITY="" \
   CODE_SIGNING_ALLOWED=NO \
   
   # Or change to:
   CODE_SIGN_IDENTITY="Apple Development" \
   CODE_SIGNING_ALLOWED=YES \
   ```

3. **Add provisioning profile** (if needed):
   ```yaml
   PROVISIONING_PROFILE_SPECIFIER="Your Profile Name" \
   ```

### Step 3: Update Export Step

Replace the manual packaging step (lines ~47-61) with proper export:

```yaml
- name: Export .ipa
  run: |
    cat <<EOF > ExportOptions.plist
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>method</key>
      <string>development</string>
      <key>teamID</key>
      <string>YOUR_TEAM_ID</string>
      <key>signingStyle</key>
      <string>automatic</string>
    </dict>
    </plist>
    EOF

    xcodebuild -exportArchive \
      -archivePath "./build/${{ env.SCHEME_NAME }}.xcarchive" \
      -exportPath ./build \
      -exportOptionsPlist ExportOptions.plist
```

### Step 4: Update Configuration Files

Update `Configs/Release.xcconfig`:

```
DEVELOPMENT_TEAM = YOUR_TEAM_ID
CODE_SIGN_STYLE = Automatic
PRODUCT_BUNDLE_IDENTIFIER = chat.dogechat
```

### Step 5: Set Up GitHub Secrets (Optional)

For security, store your Team ID as a GitHub secret:

1. Go to your repository Settings → Secrets and variables → Actions
2. Add a new secret: `APPLE_TEAM_ID`
3. Update the workflow to use: `DEVELOPMENT_TEAM=${{ secrets.APPLE_TEAM_ID }}`

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

### "No Team Found in Archive"
- Ensure `DEVELOPMENT_TEAM` is set correctly in the archive step
- Verify the Team ID is valid in your Apple Developer account

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
