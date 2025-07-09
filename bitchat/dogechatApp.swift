//
// DogechatApp.swift
// dogechat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI
import UserNotifications

@main
struct DogechatApp: App {
    @StateObject private var chatViewModel = ChatViewModel()
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(chatViewModel)
                .onAppear {
                    NotificationDelegate.shared.chatViewModel = chatViewModel
                    #if os(iOS)
                    appDelegate.chatViewModel = chatViewModel
                    #endif
                    // Check for shared content
                    checkForSharedContent()
                }
                .onOpenURL { url in
                    handleURL(url)
                }
                #if os(iOS)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Check for shared content when app becomes active
                    checkForSharedContent()
                }
                #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #endif
    }
    
    private func handleURL(_ url: URL) {
        if url.scheme == "dogechat" && url.host == "share" {
            // Handle shared content
            checkForSharedContent()
        }
    }
    
    private func checkForSharedContent() {
        // Check app group for shared content from extension
        guard let userDefaults = UserDefaults(suiteName: "group.chat.dogechat") else {
            print("DEBUG: Failed to access app group UserDefaults")
            return
        }
        
        guard let sharedContent = userDefaults.string(forKey: "sharedContent"),
              let sharedDate = userDefaults.object(forKey: "sharedContentDate") as? Date else {
            print("DEBUG: No shared content found in UserDefaults")
            return
        }
        
        print("DEBUG: Found shared content: \(sharedContent)")
        print("DEBUG: Shared date: \(sharedDate)")
        print("DEBUG: Time since shared: \(Date().timeIntervalSince(sharedDate)) seconds")
        
        // Only process if shared within last 30 seconds
        if Date().timeIntervalSince(sharedDate) < 30 {
            let contentType = userDefaults.string(forKey: "sharedContentType") ?? "text"
            print("DEBUG: Content type: \(contentType)")
            
            // Clear the shared content
            userDefaults.removeObject(forKey: "sharedContent")
            userDefaults.removeObject(forKey: "sharedContentType")
            userDefaults.removeObject(forKey: "sharedContentDate")
            userDefaults.synchronize()
            
            // Show notification about shared content
            DispatchQueue.main.async {
                // Add system message about sharing
                let systemMessage = DogechatMessage(
                    sender: "system",
                    content: "preparing to share \(contentType)...",
                    timestamp: Date(),
                    isRelay: false
                )
                self.chatViewModel.messages.append(systemMessage)
            }
            
            // Send the shared content after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if contentType == "url" {
                    print("DEBUG: Processing URL content")
                    // Try to parse as JSON first
                    if let data = sharedContent.data(using: .utf8),
                       let urlData = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                       let url = urlData["url"],
                       ... // continue unchanged logic
