//
// DogechatProtocol.swift
// dogechat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import Foundation
import CryptoKit

// Privacy-preserving padding utilities
struct MessagePadding {
    static let blockSizes = [256, 512, 1024, 2048]
    static func pad(_ data: Data, toSize targetSize: Int) -> Data {
        guard data.count < targetSize else { return data }
        let paddingNeeded = targetSize - data.count
        guard paddingNeeded <= 255 else { return data }
        var padded = data
        var randomBytes = [UInt8](repeating: 0, count: paddingNeeded - 1)
        _ = SecRandomCopyBytes(kSecRandomDefault, paddingNeeded - 1, &randomBytes)
        padded.append(contentsOf: randomBytes)
        padded.append(UInt8(paddingNeeded))
        return padded
    }
    static func unpad(_ data: Data) -> Data {
        guard !data.isEmpty else { return data }
        let paddingLength = Int(data[data.count - 1])
        guard paddingLength > 0 && paddingLength <= data.count else { return data }
        return data.prefix(data.count - paddingLength)
    }
    static func optimalBlockSize(for dataSize: Int) -> Int {
        let totalSize = dataSize + 16
        for blockSize in blockSizes {
            if totalSize <= blockSize {
                return blockSize
            }
        }
        return dataSize
    }
}

enum MessageType: UInt8 {
    case announce = 0x01
    case keyExchange = 0x02
    case leave = 0x03
    case message = 0x04
    case fragmentStart = 0x05
    case fragmentContinue = 0x06
    case fragmentEnd = 0x07
    case channelAnnounce = 0x08
    case channelRetention = 0x09
    case deliveryAck = 0x0A
    case deliveryStatusRequest = 0x0B
    case readReceipt = 0x0C
}

struct SpecialRecipients {
    static let broadcast = Data(repeating: 0xFF, count: 8)
}

struct DogechatPacket: Codable {
    let version: UInt8
    let type: UInt8
    let senderID: Data
    let recipientID: Data?
    let timestamp: UInt64
    let payload: Data
    let signature: Data?
    var ttl: UInt8

    init(type: UInt8, senderID: Data, recipientID: Data?, timestamp: UInt64, payload: Data, signature: Data?, ttl: UInt8) {
        self.version = 1
        self.type = type
        self.senderID = senderID
        self.recipientID = recipientID
        self.timestamp = timestamp
        self.payload = payload
        self.signature = signature
        self.ttl = ttl
    }
    init(type: UInt8, ttl: UInt8, senderID: String, payload: Data) {
        self.version = 1
        self.type = type
        self.senderID = senderID.data(using: .utf8)!
        self.recipientID = nil
        self.timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        self.payload = payload
        self.signature = nil
        self.ttl = ttl
    }
    var data: Data? { BinaryProtocol.encode(self) }
    func toBinaryData() -> Data? { BinaryProtocol.encode(self) }
    static func from(_ data: Data) -> DogechatPacket? { BinaryProtocol.decode(data) }
}

struct DeliveryAck: Codable {
    let originalMessageID: String
    let ackID: String
    let recipientID: String
    let recipientNickname: String
    let timestamp: Date
    let hopCount: UInt8

    init(originalMessageID: String, recipientID: String, recipientNickname: String, hopCount: UInt8) {
        self.originalMessageID = originalMessageID
        self.ackID = UUID().uuidString
        self.recipientID = recipientID
        self.recipientNickname = recipientNickname
        self.timestamp = Date()
        self.hopCount = hopCount
    }
    func encode() -> Data? { try? JSONEncoder().encode(self) }
    static func decode(from data: Data) -> DeliveryAck? { try? JSONDecoder().decode(DeliveryAck.self, from: data) }
}

struct ReadReceipt: Codable {
    let originalMessageID: String
    let receiptID: String
    let readerID: String
    let readerNickname: String
    let timestamp: Date

    init(originalMessageID: String, readerID: String, readerNickname: String) {
        self.originalMessageID = originalMessageID
        self.receiptID = UUID().uuidString
        self.readerID = readerID
        self.readerNickname = readerNickname
        self.timestamp = Date()
    }
    func encode() -> Data? { try? JSONEncoder().encode(self) }
    static func decode(from data: Data) -> ReadReceipt? { try? JSONDecoder().decode(ReadReceipt.self, from: data) }
}

enum DeliveryStatus: Codable, Equatable {
    case sending
    case sent
    case delivered(to: String, at: Date)
    case read(by: String, at: Date)
    case failed(reason: String)
    case partiallyDelivered(reached: Int, total: Int)
    var displayText: String {
        switch self {
        case .sending: return "Sending..."
        case .sent: return "Sent"
        case .delivered(let nickname, _): return "Delivered to \(nickname)"
        case .read(let nickname, _): return "Read by \(nickname)"
        case .failed(let reason): return "Failed: \(reason)"
        case .partiallyDelivered(let reached, let total): return "Delivered to \(reached)/\(total)"
        }
    }
}

struct DogechatMessage: Codable, Equatable {
    let id: String
    let sender: String
    let content: String
    let timestamp: Date
    let isRelay: Bool
    let originalSender: String?
    let isPrivate: Bool
    let recipientNickname: String?
    let senderPeerID: String?
    let mentions: [String]?
    let channel: String?
    let encryptedContent: Data?
    let isEncrypted: Bool
    var deliveryStatus: DeliveryStatus?

    init(id: String? = nil, sender: String, content: String, timestamp: Date, isRelay: Bool, originalSender: String? = nil, isPrivate: Bool = false, recipientNickname: String? = nil, senderPeerID: String? = nil, mentions: [String]? = nil, channel: String? = nil, encryptedContent: Data? = nil, isEncrypted: Bool = false, deliveryStatus: DeliveryStatus? = nil) {
        self.id = id ?? UUID().uuidString
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
        self.isRelay = isRelay
        self.originalSender = originalSender
        self.isPrivate = isPrivate
        self.recipientNickname = recipientNickname
        self.senderPeerID = senderPeerID
        self.mentions = mentions
        self.channel = channel
        self.encryptedContent = encryptedContent
        self.isEncrypted = isEncrypted
        self.deliveryStatus = deliveryStatus ?? (isPrivate ? .sending : nil)
    }
}

protocol DogechatDelegate: AnyObject {
    func didReceiveMessage(_ message: DogechatMessage)
    func didConnectToPeer(_ peerID: String)
    func didDisconnectFromPeer(_ peerID: String)
    func didUpdatePeerList(_ peers: [String])
    func didReceiveChannelLeave(_ channel: String, from peerID: String)
    func didReceivePasswordProtectedChannelAnnouncement(_ channel: String, isProtected: Bool, creatorID: String?, keyCommitment: String?)
    func didReceiveChannelRetentionAnnouncement(_ channel: String, enabled: Bool, creatorID: String?)
    func decryptChannelMessage(_ encryptedContent: Data, channel: String) -> String?
    func isFavorite(fingerprint: String) -> Bool
    func didReceiveDeliveryAck(_ ack: DeliveryAck)
    func didReceiveReadReceipt(_ receipt: ReadReceipt)
    func didUpdateMessageDeliveryStatus(_ messageID: String, status: DeliveryStatus)
}

extension DogechatDelegate {
    func isFavorite(fingerprint: String) -> Bool { return false }
    func didReceiveChannelLeave(_ channel: String, from peerID: String) {}
    func didReceivePasswordProtectedChannelAnnouncement(_ channel: String, isProtected: Bool, creatorID: String?, keyCommitment: String?) {}
    func didReceiveChannelRetentionAnnouncement(_ channel: String, enabled: Bool, creatorID: String?) {}
    func decryptChannelMessage(_ encryptedContent: Data, channel: String) -> String? { return nil }
    func didReceiveDeliveryAck(_ ack: DeliveryAck) {}
    func didReceiveReadReceipt(_ receipt: ReadReceipt) {}
    func didUpdateMessageDeliveryStatus(_ messageID: String, status: DeliveryStatus) {}
}
