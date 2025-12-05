//
//  SocialsChatView.swift
//  IosDam
//
//  Created by macbook on 1/12/2025.
//

import SwiftUI

// MARK: - Social Stats Model

struct SocialStats {
    var friendsCount: Int
    var teamsCount: Int
    var rank: Int
}

// MARK: - Main View

struct SocialsChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var stats = SocialStats(friendsCount: 12, teamsCount: 2, rank: 24)
    
    // ⭐️ States to control programmatic navigation
    @State private var navigateToFriends = false
    @State private var navigateToTeams = false
    
    var body: some View {
        // 1. Wrap the entire view in a NavigationView to enable pushing views
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                // 2. Hidden NavigationLinks to handle the transitions
                NavigationLink(destination: FriendsSocialView(), isActive: $navigateToFriends) { EmptyView() }
                NavigationLink(destination: TeamsSocialView(), isActive: $navigateToTeams) { EmptyView() }
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Social Hub")
                                .font(.system(size: 28, weight: .bold))
                            Text("Connect and compete")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Close button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                                .frame(width: 32, height: 32)
                                .background(Color(UIColor.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // Friends Card
                            SocialMenuCard(
                                icon: "person.2.fill",
                                iconColor: .blue,
                                title: "Friends",
                                subtitle: "Manage your connections"
                            ) {
                                // ⭐️ Action: Activate the NavigationLink
                                navigateToFriends = true
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            // Teams Card
                            SocialMenuCard(
                                icon: "shield.fill",
                                iconColor: .purple,
                                title: "Teams",
                                subtitle: "View and manage teams"
                            ) {
                                // ⭐️ Action: Activate the NavigationLink
                                navigateToTeams = true
                            }
                            .padding(.horizontal)
                            
                            // Leaderboard Card
                            SocialMenuCard(
                                icon: "trophy.fill",
                                iconColor: .orange,
                                title: "Leaderboard",
                                subtitle: "Top players & teams"
                            ) {
                                // This action doesn't navigate to a specific view yet
                                print("Navigate to Leaderboard")
                            }
                            .padding(.horizontal)
                            
                            // Stats Cards
                            HStack(spacing: 12) {
                                SocialStatBox(
                                    value: "\(stats.friendsCount)",
                                    label: "Friends",
                                    color: Color.green
                                )
                                
                                SocialStatBox(
                                    value: "\(stats.teamsCount)",
                                    label: "Teams",
                                    color: Color.blue
                                )
                                
                                SocialStatBox(
                                    value: "#\(stats.rank)",
                                    label: "Rank",
                                    color: Color.orange
                                )
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true) // Hide the navigation bar on the root view
        }
        // Use StackNavigationViewStyle for consistent behavior on iPad
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Social Menu Card Component

struct SocialMenuCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon Circle
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(iconColor)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(red: 0.9, green: 0.95, blue: 0.93))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle()) // Ensures button styling doesn't interfere
    }
}

// MARK: - Social Stat Box Component

struct SocialStatBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(red: 0.9, green: 0.95, blue: 0.93))
        .cornerRadius(16)
    }
}

// MARK: - Preview

struct SocialsChatView_Previews: PreviewProvider {
    static var previews: some View {
        SocialsChatView()
    }
}
