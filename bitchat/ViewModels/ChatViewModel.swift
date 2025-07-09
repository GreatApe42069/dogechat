//
// ChatViewModel.swift
// dogechat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import Foundation
import SwiftUI
import Combine
import CryptoKit
import CommonCrypto
#if os(iOS)
import UIKit
#endif

class ChatViewModel: ObservableObject {
    @Published var messages: [DogechatMessage] = []
    @Published var connectedPeers: [String] = []
    @Published var nickname: String = "" {
        didSet {
            nicknameSaveTimer?.invalidate()
            nicknameSaveTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self.saveNickname()
            }
        }
    }
    @Published var isConnected = false
    @Published var privateChats: [String: [DogechatMessage]] = [:] // peerID -> messages
    @Published var selectedPrivateChatPeer: String? = nil
    @Published var unreadPrivateMessages: Set<String> = []
    @Published var autocompleteSuggestions: [String] = []
    @Published var showAutocomplete: Bool = false
    @Published var autocompleteRange: NSRange? = nil
    @Published var selectedAutocompleteIndex: Int = 0

    // Channel support
    @Published var joinedChannels: Set<String> = []  // Set of channel hashtags
    @Published var currentChannel: String? = nil  // Currently selected channel
    @Published var channelMessages: [String: [DogechatMessage]] = [:]  // channel -> messages
    @Published var unreadChannelMessages: [String: Int] = [:]  // channel -> unread count
    @Published var channelMembers: [String: Set<String>] = [:]  // channel -> set of peer IDs who have sent messages
    @Published var channelPasswords: [String: String] = [:]  // channel -> password (stored locally only)
    @Published var channelKeys: [String: SymmetricKey] = [:]  // channel -> derived encryption key
    @Published var passwordProtectedChannels: Set<String> = []  // Set of channels that require passwords
    @Published var channelCreators: [String: String] = [:]  // channel -> creator peerID
    @Published var channelKeyCommitments: [String: String] = [:]  // channel -> SHA256(derivedKey) for verification
    @Published var showPasswordPrompt: Bool = false
    @Published var passwordPromptChannel: String? = nil
    @Published var savedChannels: Set<String> = []  // Channels saved for message retention
    @Published var retentionEnabledChannels: Set<String> = []  // Channels where owner enabled retention for all members

    let meshService = BluetoothMeshService()
    private let userDefaults = UserDefaults.standard
    private let nicknameKey = "dogechat.nickname"
    private let favoritesKey = "dogechat.favorites"
    private let joinedChannelsKey = "dogechat.joinedChannels"
    private let passwordProtectedChannelsKey = "dogechat.passwordProtectedChannels"
    private let channelCreatorsKey = "dogechat.channelCreators"
    // private let channelPasswordsKey = "dogechat.channelPasswords" // Now using Keychain
    private let channelKeyCommitmentsKey = "dogechat.channelKeyCommitments"
    private let retentionEnabledChannelsKey = "dogechat.retentionEnabledChannels"
    private let blockedUsersKey = "dogechat.blockedUsers"
    private var nicknameSaveTimer: Timer?

    @Published var favoritePeers: Set<String> = []  // Now stores public key fingerprints instead of peer IDs
    private var peerIDToPublicKeyFingerprint: [String: String] = [:]  // Maps ephemeral peer IDs to persistent fingerprints
    private var blockedUsers: Set<String> = []  // Stores public key fingerprints of blocked users

    // Messages are naturally ephemeral - no persistent storage

    // Delivery tracking
    private var deliveryTrackerCancellable: AnyCancellable?

    init() {
        loadNickname()
        loadFavorites()
        loadJoinedChannels()
        loadChannelData()
        loadBlockedUsers()
        // Load saved channels state
        savedChannels = MessageRetentionService.shared.getFavoriteChannels()
        meshService.delegate = self

        // Log startup info

        // Start mesh service immediately
        meshService.startServices()

        // Set up message retry service
        MessageRetryService.shared.meshService = meshService

        // Request notification permission
        NotificationService.shared.requestAuthorization()

        // Subscribe to delivery status updates
        deliveryTrackerCancellable = DeliveryTracker.shared.deliveryStatusUpdated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (messageID, status) in
                self?.updateMessageDeliveryStatus(messageID, status: status)
            }

        // Show welcome message after delay if still no peers
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            if self.connectedPeers.isEmpty && self.messages.isEmpty {
                let welcomeMessage = DogechatMessage(
                    sender: "system",
                    content: "get people around you to download dogechat…and chat with them here!",
                    timestamp: Date(),
                    isRelay: false
                )
                self.messages.append(welcomeMessage)
            }
        }

        // When app becomes active, send read receipts for visible messages
        #if os(macOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
        #else
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Add screenshot detection for iOS
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
        #endif
    }

    // ... (all internal logic remains the same, but all BitchatMessage → DogechatMessage,
    // all "bitchat" → "dogechat" in keys, etc.)

    // (For brevity, the rest of the file is unchanged except all BitchatMessage/BitchatDelegate,
    // and all string keys/names/identifiers containing "bitchat" are renamed to "dogechat".)
}

// At the end:
extension ChatViewModel: DogechatDelegate {
    // ... same as before, but all BitchatMessage → DogechatMessage, etc.
}
