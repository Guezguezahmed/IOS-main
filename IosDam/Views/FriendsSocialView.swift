//
//  FriendsSocialView.swift
//  IosDam
//
//  Created by macbook on 1/12/2025.
//

import SwiftUI

// MARK: - Models

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let avatarColor: Color
    let wins: Int
    let winRate: Int
    
    var initials: String {
        name.split(separator: " ").map { String($0.prefix(1)) }.joined()
    }
}

struct FriendRequest: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let mutualFriends: Int
    let avatarColor: Color
    
    var initials: String {
        name.split(separator: " ").map { String($0.prefix(1)) }.joined()
    }
}

struct SuggestedFriend: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let mutualFriends: Int
    let avatarColor: Color
    var isRequestSent: Bool = false
    
    var initials: String {
        name.split(separator: " ").map { String($0.prefix(1)) }.joined()
    }
}

enum FriendsTab {
    case friends
    case requests
    case find
}

// MARK: - Main View

struct FriendsSocialView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: FriendsTab = .friends
    @State private var searchText: String = ""
    @State private var notificationCount: Int = 2
    
    // Sample Data
    @State private var friends: [Friend] = [
        Friend(name: "Marcus Silva", username: "@marcus", avatarColor: Color(red: 0.4, green: 0.7, blue: 0.5), wins: 45, winRate: 78),
        Friend(name: "Jordan Lee", username: "@jordan", avatarColor: Color(red: 0.4, green: 0.7, blue: 0.5), wins: 38, winRate: 72),
        Friend(name: "Alex Chen", username: "@alex", avatarColor: Color(red: 0.4, green: 0.7, blue: 0.5), wins: 52, winRate: 81),
        Friend(name: "Sam Taylor", username: "@samtay", avatarColor: Color(red: 0.4, green: 0.7, blue: 0.5), wins: 41, winRate: 75),
        Friend(name: "Riley Brooks", username: "@riley", avatarColor: Color(red: 0.4, green: 0.7, blue: 0.5), wins: 29, winRate: 68)
    ]
    
    @State private var requests: [FriendRequest] = [
        FriendRequest(name: "Chris Martin", username: "@chris", mutualFriends: 3, avatarColor: Color.purple),
        FriendRequest(name: "Taylor Swift", username: "@tswift", mutualFriends: 5, avatarColor: Color.purple)
    ]
    
    @State private var suggested: [SuggestedFriend] = [
        SuggestedFriend(name: "Morgan Blake", username: "@morgan", mutualFriends: 8, avatarColor: Color.blue, isRequestSent: true),
        SuggestedFriend(name: "Casey Jordan", username: "@casey", mutualFriends: 6, avatarColor: Color.blue),
        SuggestedFriend(name: "Avery Quinn", username: "@avery", mutualFriends: 4, avatarColor: Color.blue),
        SuggestedFriend(name: "Tony Kemp", username: "@tkemp", mutualFriends: 2, avatarColor: Color.red)
    ]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    ZStack(alignment: .topTrailing) {
                        Button(action: {}) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.primary)
                        }
                        
                        if notificationCount > 0 {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 18, height: 18)
                                .overlay(
                                    Text("\(notificationCount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 6, y: -6)
                        }
                    }
                }
                .padding()
                
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Friends")
                        .font(.system(size: 28, weight: .bold))
                    Text("Connect with players")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Tabs
                HStack(spacing: 12) {
                    TabButton(
                        title: "Friends \(friends.count)",
                        isSelected: selectedTab == .friends
                    ) {
                        selectedTab = .friends
                    }
                    
                    TabButton(
                        title: "Requests",
                        hasNotification: requests.count > 0,
                        isSelected: selectedTab == .requests
                    ) {
                        selectedTab = .requests
                    }
                    
                    TabButton(
                        title: "Find",
                        isSelected: selectedTab == .find
                    ) {
                        selectedTab = .find
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search friends...", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding()
                .background(Color(red: 0.9, green: 0.95, blue: 0.93))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Content based on selected tab
                ScrollView {
                    if selectedTab == .friends {
                        FriendsListContent(friends: friends)
                    } else if selectedTab == .requests {
                        RequestsContent(requests: $requests)
                    } else {
                        FindFriendsContent(suggested: $suggested)
                    }
                }
                .padding(.top, 8)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let title: String
    var hasNotification: Bool = false
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(red: 0.4, green: 0.7, blue: 0.6) : .secondary)
                
                if hasNotification {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color(red: 0.9, green: 0.95, blue: 0.93) : Color.clear)
            .cornerRadius(8)
        }
    }
}

// MARK: - Friends List Content

struct FriendsListContent: View {
    let friends: [Friend]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(friends) { friend in
                FriendCard(friend: friend)
            }
        }
        .padding(.horizontal)
    }
}

struct FriendCard: View {
    let friend: Friend
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(friend.avatarColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(friend.initials)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(friend.username)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text("🏆")
                            .font(.system(size: 12))
                        Text("\(friend.wins) wins")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                        Text("\(friend.winRate)%")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Message Button
            Button(action: {}) {
                Image(systemName: "message.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.4, green: 0.7, blue: 0.6))
                    .frame(width: 36, height: 36)
                    .background(Color(red: 0.4, green: 0.7, blue: 0.6).opacity(0.15))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(red: 0.9, green: 0.95, blue: 0.93))
        .cornerRadius(12)
    }
}

// MARK: - Requests Content

struct RequestsContent: View {
    @Binding var requests: [FriendRequest]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pending Requests")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)
            
            ForEach(requests) { request in
                RequestCard(request: request) { action in
                    if action == .accept {
                        // Handle accept
                        requests.removeAll { $0.id == request.id }
                    } else {
                        // Handle decline
                        requests.removeAll { $0.id == request.id }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct RequestCard: View {
    let request: FriendRequest
    let onAction: (RequestAction) -> Void
    
    enum RequestAction {
        case accept, decline
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(request.avatarColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(request.initials)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(request.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(request.username)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Text("\(request.mutualFriends) mutual friends")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: { onAction(.decline) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(8)
                }
                
                Button(action: { onAction(.accept) }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(red: 0.4, green: 0.7, blue: 0.6))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(red: 0.9, green: 0.95, blue: 0.93))
        .cornerRadius(12)
    }
}

// MARK: - Find Friends Content

struct FindFriendsContent: View {
    @Binding var suggested: [SuggestedFriend]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggested Friends")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)
            
            ForEach(suggested.indices, id: \.self) { index in
                SuggestedFriendCard(
                    friend: suggested[index],
                    onToggle: {
                        suggested[index].isRequestSent.toggle()
                    }
                )
            }
            .padding(.horizontal)
        }
    }
}

struct SuggestedFriendCard: View {
    let friend: SuggestedFriend
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(friend.avatarColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(friend.initials)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(friend.username)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Text("\(friend.mutualFriends) mutual friends")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Add/Sent Button
            Button(action: onToggle) {
                Image(systemName: friend.isRequestSent ? "checkmark" : "person.badge.plus")
                    .font(.system(size: 16))
                    .foregroundColor(friend.isRequestSent ? .green : Color(red: 0.4, green: 0.7, blue: 0.6))
                    .frame(width: 36, height: 36)
                    .background(friend.isRequestSent ? Color.green.opacity(0.15) : Color(red: 0.4, green: 0.7, blue: 0.6).opacity(0.15))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(red: 0.9, green: 0.95, blue: 0.93))
        .cornerRadius(12)
    }
}
// MARK: - Preview

struct FriendsSocialView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsSocialView()
    }
}
