//
// BluetoothMeshService.swift
// dogechat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import Foundation
import CoreBluetooth
import Combine
import CryptoKit
#if os(macOS)
import AppKit
import IOKit.ps
#else
import UIKit
#endif

// Extension for hex encoding
extension Data {
    func hexEncodedString() -> String {
        if self.isEmpty {
            return ""
        }
        return self.map { String(format: "%02x", $0) }.joined()
    }
}

class BluetoothMeshService: NSObject {
    static let serviceUUID = CBUUID(string: "F47B5E2D-4A9E-4C5A-9B3F-8E1D2C3A4B5C")
    static let characteristicUUID = CBUUID(string: "A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D")
    
    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?
    private var discoveredPeripherals: [CBPeripheral] = []
    private var connectedPeripherals: [String: CBPeripheral] = [:]
    private var peripheralCharacteristics: [CBPeripheral: CBCharacteristic] = [:]
    private var characteristic: CBMutableCharacteristic?
    private var subscribedCentrals: [CBCentral] = []
    private var peerNicknames: [String: String] = [:]
    private let peerNicknamesLock = NSLock()
    private var activePeers: Set<String> = []  // Track all active peers
    private let activePeersLock = NSLock()  // Thread safety for activePeers
    private var peerRSSI: [String: NSNumber] = [:] // Track RSSI values for peers
    private var peripheralRSSI: [String: NSNumber] = [:] // Track RSSI by peripheral ID during discovery
    private var loggedCryptoErrors = Set<String>()  // Track which peers we've logged crypto errors for
    
    weak var delegate: DogechatDelegate?
    private let encryptionService = EncryptionService()
    private let messageQueue = DispatchQueue(label: "dogechat.messageQueue", attributes: .concurrent)
    private var processedMessages = Set<String>()
    private let maxTTL: UInt8 = 7  // Maximum hops for long-distance delivery
    private var announcedToPeers = Set<String>()  // Track which peers we've announced to
    private var announcedPeers = Set<String>()  // Track peers who have already been announced
    private var processedKeyExchanges = Set<String>()  // Track processed key exchanges to prevent duplicates
    private var intentionalDisconnects = Set<String>()  // Track peripherals we're disconnecting intentionally
    private var peerLastSeenTimestamps: [String: Date] = [:]  // Track when we last heard from each peer
    private var cleanupTimer: Timer?  // Timer to clean up stale peers
    
    // Store-and-forward message cache
    private struct StoredMessage {
        let packet: DogechatPacket
        let timestamp: Date
        let messageID: String
        let isForFavorite: Bool  // Messages for favorites stored indefinitely
    }
    private var messageCache: [StoredMessage] = []
    private let messageCacheTimeout: TimeInterval = 43200  // 12 hours for regular peers
    private let maxCachedMessages = 100  // For regular peers
    private let maxCachedMessagesForFavorites = 1000  // Much larger cache for favorites
    private var favoriteMessageQueue: [String: [StoredMessage]] = [:]  // Per-favorite message queues
    private var deliveredMessages: Set<String> = []  // Track delivered message IDs to prevent duplicates
    private var cachedMessagesSentToPeer: Set<String> = []  // Track which peers have already received cached messages
    private var receivedMessageTimestamps: [String: Date] = [:]  // Track timestamps of received messages for debugging
    private var recentlySentMessages: Set<String> = []  // Short-term cache to prevent any duplicate sends
    private let recentlySentMessagesLock = NSLock()  // Thread safety for recentlySentMessages
    private var lastMessageFromPeer: [String: Date] = [:]  // Track last message time from each peer for connection prioritization
    
    // Battery and range optimizations
    private var scanDutyCycleTimer: Timer?
    private var isActivelyScanning = true
    private var activeScanDuration: TimeInterval = 2.0  // Scan actively for 2 seconds - will be adjusted based on battery
    private var scanPauseDuration: TimeInterval = 3.0  // Pause for 3 seconds - will be adjusted based on battery
    private var lastRSSIUpdate: [String: Date] = [:]  // Throttle RSSI updates
    private var batteryMonitorTimer: Timer?
    private var currentBatteryLevel: Float = 1.0  // Default to full battery
    
    // Battery optimizer integration
    private let batteryOptimizer = BatteryOptimizer.shared
    private var batteryOptimizerCancellables = Set<AnyCancellable>()
    
    // Peer list update debouncing
    private var peerListUpdateTimer: Timer?
    private let peerListUpdateDebounceInterval: TimeInterval = 0.1  // 100ms debounce for more responsive updates
    
    // Cover traffic for privacy
    private var coverTrafficTimer: Timer?
    private let coverTrafficPrefix = "☂DUMMY☂"  // Prefix to identify dummy messages after decryption
    private var lastCoverTrafficTime = Date()
    private var advertisingTimer: Timer?  // Timer for interval-based advertising
    
    // Timing randomization for privacy
    private let minMessageDelay: TimeInterval = 0.01  // 10ms minimum for faster sync
    private let maxMessageDelay: TimeInterval = 0.1   // 100ms maximum for faster sync
    
