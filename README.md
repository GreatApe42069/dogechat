<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/3e095140-d7a4-434f-88dd-97acd9a421fe" />


## dogechat iOS

A decentralized peer-to-peer messaging app with dual transport architecture: local Bluetooth mesh networks for offline communication and internet-based Nostr protocol for global reach. No accounts, no phone numbers, no central servers. It's the side-groupchat.

[dogechat iOS git page coming soon](https://greatape42069.github.io/dogechat)

📲 [App Store Coming Soon](https://apps.apple.com/us/app/dogechat-mesh/idxxxxxxx)

## Installation

### Official App Store (Recommended)
Download from the [App Store Coming Soon](https://apps.apple.com/us/app/dogechat-mesh/idxxxxxx) for the easiest installation experience.

### Unsigned Builds (Alternative)
For users who prefer sideloading or need unsigned builds:

- 📱 **AltStore/SideStore Users**: Download and install with your FREE Apple ID
- 🔓 **Jailbroken Devices**: Install permanently without expiration
- 🛠️ **Advanced Users**: Manual signing with your own tools

**[📖 Full Installation Guide for Unsigned Builds](INSTALL_IOS.md)**

Download the latest unsigned build: [ios-latest-unsigned release](https://github.com/GreatApe42069/dogechat/releases/tag/ios-latest-unsigned)

### 🎯 The Truth

***Our unsigned IPA currently has NO certificate at all. That's actually the brilliant part of our current dogechat iOS setup!***


**Our Current Unsigned IPA:**

- ❌ Has zero certificates in it

- ✅ Users sign it themselves with their own Apple ID

- ✅ Each user trusts their own certificate (not Ours)

- ✅ Works for unlimited users

- ✅ No trust/certificate installation needed


**If We Made a Signed IPA (with a free Apple ID):**


- ✅ Pre-signed with your certificate

- ❌ Only works for people who manually install and trust OUR certificate

- ❌ Requires users to download your certificate profile

- ❌ Still expires in 7 days

- ❌ More complicated for end users

- ❌ Limited to devices you manually add to your Apple Developer portal


**Our current unsigned workflow is BETTER than a free Apple ID signed version!**


Here's why:

***Unsigned (Ours Currently)*** 	
- Users needed to trust certificate: No (they use their own)
- Number of users: Unlimited
- User setup complexity: Very Easy (AltStore handles it)
- Expiration: 7 days (auto-renewable via AltStore)
- Cost: FREE

***Signed with Free Apple ID***
- Users needed to trust certificate: Yes (manual certificate install) 
- Number of users: Limited (~100 devices manually registered)
- User setup complexity: Complex (certificate + trust + IPA)
- Expiration: 7 days (requires re-download)
- Cost: FREE

***Signed with Paid Dev Account***
- Users needed to trust certificate: No (Apple trusts it)
- Number of users: Unlimited
- User setup complexity: Easy (TestFlight/App Store handles it)
- Expiration : No expiration
- Cost : $99/year


## [Features](https://github.com/GreatApe42069/dogechat/blob/main/WHITEPAPER.md)

- **Dual Transport Architecture**: Bluetooth mesh for offline + Nostr protocol for internet-based messaging
- **Location-Based Channels**: Geographic chat rooms using geohash coordinates over global Nostr relays
- **Intelligent Message Routing**: Automatically chooses best transport (Bluetooth → Nostr fallback)
- **Decentralized Mesh Network**: Automatic peer discovery and multi-hop message relay over Bluetooth LE
- **Privacy First**: No accounts, no phone numbers, no persistent identifiers
- **Private Message End-to-End Encryption**: [Noise Protocol](https://noiseprotocol.org) for mesh, NIP-17 for Nostr
- **IRC-Style Commands**: Familiar `/slap`, `/msg`, `/who` style interface
- **Universal App**: Native support for iOS and macOS
- **Emergency Wipe**: Triple-tap to instantly clear all data
- **Performance Optimizations**: LZ4 message compression, adaptive battery modes, and optimized networking

## [Technical Architecture](https://deepwiki.com/GreatApe42069/dogechat)

DogeChat uses a **hybrid messaging architecture** with two complementary transport layers:

### Bluetooth Mesh Network (Offline)

- **Local Communication**: Direct peer-to-peer within Bluetooth range
- **Multi-hop Relay**: Messages route through nearby devices (max 7 hops)
- **No Internet Required**: Works completely offline in disaster scenarios
- **Noise Protocol Encryption**: End-to-end encryption with forward secrecy
- **Binary Protocol**: Compact packet format optimized for Bluetooth LE constraints
- **Automatic Discovery**: Peer discovery and connection management
- **Adaptive Power**: Battery-optimized duty cycling

### Nostr Protocol (Internet)

- **Global Reach**: Connect with users worldwide via internet relays
- **Location Channels**: Geographic chat rooms using geohash coordinates
- **290+ Relay Network**: Distributed across the globe for reliability
- **NIP-17 Encryption**: Gift-wrapped private messages for internet privacy
- **Ephemeral Keys**: Fresh cryptographic identity per geohash area

### Channel Types

#### `mesh #bluetooth`

- **Transport**: Bluetooth Low Energy mesh network
- **Scope**: Local devices within multi-hop range
- **Internet**: Not required
- **Use Case**: Offline communication, protests, disasters, remote areas

#### Location Channels (`block #dr5rsj7`, `neighborhood #dr5rs`, `country #dr`)

- **Transport**: Nostr protocol over internet
- **Scope**: Geographic areas defined by geohash precision
  - `block` (7 chars): City block level
  - `neighborhood` (6 chars): District/neighborhood
  - `city` (5 chars): City level
  - `province` (4 chars): State/province
  - `region` (2 chars): Country/large region
- **Internet**: Required (connects to Nostr relays)
- **Use Case**: Location-based community chat, local events, regional discussions

### Direct Message Routing

Private messages use **intelligent transport selection**:

1. **Bluetooth First** (preferred when available)

   - Direct connection with established Noise session
   - Fastest and most private option

2. **Nostr Fallback** (when Bluetooth unavailable)

   - Uses recipient's Nostr public key
   - NIP-17 gift-wrapping for privacy
   - Routes through global relay network

3. **Smart Queuing** (when neither available)
   - Messages queued until transport becomes available
   - Automatic delivery when connection established

For detailed protocol documentation, see the [Technical Whitepaper](WHITEPAPER.md).

## Setup

### Option 1: Using Xcode

   ```bash
   cd dogechat
   open dogechat.xcodeproj
   ```

   To run on a device there're a few steps to prepare the code:
   - Clone the local configs: `cp Configs/Local.xcconfig.example Configs/Local.xcconfig`
   - Add your Developer Team ID into the newly created `Configs/Local.xcconfig`
      - Bundle ID would be set to `chat.dogechat.<team_id>` (unless you set to something else)
   - Entitlements need to be updated manually (TODO: Automate):
      - Search and replace `group.chat.dogechat` with `group.<your_bundle_id>` (e.g. `group.chat.dogechat.ABC123`)

### Option 2: Using `just`

   ```bash
   brew install just
   ```

Want to try this on macos: `just run` will set it up and run from source.
Run `just clean` afterwards to restore things to original state for mobile app building and development.

## Localization

- Base app resources live under `dogechat/Localization/Base.lproj/`. Add new copy to `Localizable.strings` and plural rules to `Localizable.stringsdict`.
- Share extension strings are separate in `dogechatShareExtension/Localization/Base.lproj/Localizable.strings`.
- Prefer keys that describe intent (`app_info.features.offline.title`) and reuse existing ones where possible.
- Run `xcodebuild -project dogechat.xcodeproj -scheme "dogechat (macOS)" -configuration Debug CODE_SIGNING_ALLOWED=NO build` to compile-check any localization updates.

# 🛠 Contributing

If you'd like to contribute or donate to this project, please donate in Dogecoin adddresses of contributors below. For all active contributors who wish to help improve dogechatEXT, its as easy as opening issues, and or creating pull requests.

This software is Open-source, Đecentralized, an FREE to use, Đonations are accepted, but never expected, to support The Contributers of Đogechat you can send any Donations in Dogecoin, Doginals, Dunes, or Drc-20's to the following Contributors:

---

***You can donate to*** **GreatApe** ***here:***

"handle": ***"GreatApe42069"*** "at": [***"@Greatape42069E"***](https://x.com/Greatape42069E)

 **"Đogecoin_address":** **[D9pqzxiiUke5eodEzMmxZAxpFcbvwuM4Hg](https://www.mydoge.com/GreatApe42069)**

 ---

## ***Contributions are welcome! Key areas for enhancement:***

1. **Performance**: Battery optimization and connection reliability
2. **UI/UX**: Additional Material Design 3 features
3. **Privacy**: Enhanced privacy features and NIP-07 signer support
4. **Testing**: Unit and integration test coverage
5. **Documentation**: API documentation and development guides

### Support & Issues

- **Bug Reports**: [Create an issue](../../issues) with device info and logs
- **Feature Requests**: [Start a discussion](https://github.com/orgs/greatape42069/discussions)
- **Security Issues**: Email security concerns privately
- **Android Compatibility**: Cross-reference with [original dogechat-android repo](https://github.com/GreatApe42069/dogechat-android)

---

## 📚 Additional Resources

- **[Changelog](CHANGELOG.md)** - View all updates and version history
- **[GitHub Pages Site](https://greatape42069.github.io/dogechat/)** - Official info page with Privacy Policy
- **[Privacy Policy](https://greatape42069.github.io/dogechat/#privacy)** - Required by Google Web Store

---

## 📜 License

This project is open source and available under the CC0 1.0 Universal License. 
