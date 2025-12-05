//
//  ProfileSettingsView.swift
//  IosDam
//
//  Profile Settings screen matching Android design - Xcode 12.3 Compatible

import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showLogoutDialog = false
    @State private var darkTheme = false
    @State private var dataSaver = false
    @State private var currentUserRole: String? = nil
    @State private var isLoggedOut = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            customNavigationBar
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Card
                    ProfileCardSettings()
                    
                    // Account Settings
                    SettingsSectionView(
                        title: "Account Settings",
                        items: accountSettingsItems
                    )
                    
                    // Support & About
                    SettingsSectionView(
                        title: "Support & About",
                        items: supportAboutItems
                    )
                    
                    // Cache & Cellular
                    SettingsSectionView(
                        title: "Cache & cellular",
                        items: cacheCellularItems
                    )
                    
                    // Actions
                    SettingsSectionView(
                        title: "Actions",
                        items: actionsItems
                    )
                    
                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarHidden(true)
        .onAppear(perform: loadUserRole)
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView()
        }
        .alert(isPresented: $showLogoutDialog) {
            Alert(
                title: Text("End Session"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Yes, End Session")) {
                    performLogout()
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
    
    // MARK: - Custom Navigation Bar
    
    private var customNavigationBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20))
                    .foregroundColor(Color(UIColor.label))
            }
            
            Spacer()
            
            Text("Profile")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(UIColor.label))
            
            Spacer()
            
            Button(action: {
                // Notifications action
            }) {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundColor(Color(UIColor.label))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Settings Items
    
    private var accountSettingsItems: [SettingItem] {
        var items = [
            SettingItem(icon: "person", title: "Edit Profile", iconColor: "4CAF50", type: .navigation),
            SettingItem(icon: "lock.shield", title: "Security", iconColor: "673AB7", type: .navigation),
            SettingItem(icon: "bell", title: "Notifications", iconColor: "2196F3", type: .navigation),
            SettingItem(icon: "lock", title: "Privacy", iconColor: "F44336", type: .navigation)
        ]
        
        if currentUserRole == "OWNER" {
            items.append(SettingItem(icon: "person.badge.plus", title: "Recruter arbitre", iconColor: "4CAF50", type: .navigation))
            items.append(SettingItem(icon: "building.2", title: "Stadiums", iconColor: "673AB7", type: .navigation))
            items.append(SettingItem(icon: "person.3", title: "My Teams", iconColor: "2196F3", type: .navigation))
        }
        
        return items
    }
    
    private var supportAboutItems: [SettingItem] {
        [
            SettingItem(icon: "creditcard", title: "My Subscription", iconColor: "4CAF50", type: .navigation),
            SettingItem(icon: "questionmark.circle", title: "Help & Support", iconColor: "673AB7", type: .navigation),
            SettingItem(icon: "info.circle", title: "Terms and Policies", iconColor: "2196F3", type: .navigation)
        ]
    }
    
    private var cacheCellularItems: [SettingItem] {
        [
            SettingItem(icon: "trash", title: "Free up space", iconColor: "F44336", type: .navigation),
            SettingItem(icon: "paintbrush", title: "Theme Selection", iconColor: "4CAF50", type: .toggle(binding: $darkTheme)),
            SettingItem(icon: "antenna.radiowaves.left.and.right", title: "Data Saver", iconColor: "673AB7", type: .toggle(binding: $dataSaver))
        ]
    }
    
    private var actionsItems: [SettingItem] {
        [
            SettingItem(icon: "flag", title: "Report a problem", iconColor: "F44336", type: .action),
            SettingItem(icon: "person.crop.circle.badge.plus", title: "Add account", iconColor: "4CAF50", type: .action),
            SettingItem(icon: "rectangle.portrait.and.arrow.right", title: "Log out", iconColor: "F44336", type: .action)
        ]
    }
    
    // MARK: - Functions
    
    func loadUserRole() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserModel.self, from: userData) {
            currentUserRole = user.role
        }
    }
    
    func performLogout() {
        UserDefaults.standard.removeObject(forKey: "userToken")
        UserDefaults.standard.removeObject(forKey: "currentUser")
        isLoggedOut = true
    }
    
    func handleItemTap(_ item: SettingItem) {
        if item.title == "Log out" {
            showLogoutDialog = true
        }
        // Add other navigation handlers here
    }
}

// MARK: - Profile Card Settings

struct ProfileCardSettings: View {
    @State private var user: UserModel?
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            if let picture = user?.picture, !picture.isEmpty,
               let imageData = Data(base64Encoded: picture),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .frame(width: 100, height: 100)
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            
            // Name
            Text("Hello, \(user?.fullName ?? "User")")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(UIColor.label))
            
            // Phone
            Text(user?.tel != nil ? "+\(user!.tel)" : "No phone")
                .font(.system(size: 16))
                .foregroundColor(Color(UIColor.secondaryLabel))
            
            // Department Badge
            HStack(spacing: 6) {
                Image(systemName: "building.2")
                    .font(.system(size: 14))
                    .foregroundColor(Color.white)
                Text(user?.role ?? "User")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(hex: "4CAF50"))
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .onAppear(perform: loadUser)
    }
    
    func loadUser() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let decodedUser = try? JSONDecoder().decode(UserModel.self, from: userData) {
            user = decodedUser
        }
    }
}

// MARK: - Settings Section

struct SettingsSectionView: View {
    let title: String
    let items: [SettingItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(UIColor.label))
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    SettingsRowView(item: item, showDivider: index < items.count - 1)
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Settings Row

struct SettingsRowView: View {
    let item: SettingItem
    let showDivider: Bool
    @State private var navigateToRecrute = false
    @State private var navigateToStades = false
    @State private var navigateToTeams = false
    @State private var showLogoutDialog = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                handleTap()
            }) {
                HStack(spacing: 16) {
                    // Icon with background
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: item.iconColor).opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: item.icon)
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: item.iconColor))
                    }
                    
                    // Title
                    Text(item.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(UIColor.label))
                    
                    Spacer()
                    
                    // Trailing content
                    trailingContent
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(PlainButtonStyle())
            
            if showDivider {
                Divider()
                    .padding(.leading, 16)
            }
        }
        .background(
            Group {
                NavigationLink(destination: RecruteView(idAcademie: getUserId()), isActive: $navigateToRecrute) {
                    EmptyView()
                }
                NavigationLink(destination: StadiumsListView(), isActive: $navigateToStades) {
                    EmptyView()
                }
                NavigationLink(destination: TeamsListView(), isActive: $navigateToTeams) {
                    EmptyView()
                }
            }
        )
    }
    
    // MARK: - Helper Functions
    
    func handleTap() {
        switch item.title {
        case "Recruter arbitre":
            navigateToRecrute = true
        case "Stadiums":
            navigateToStades = true
        case "My Teams":
            navigateToTeams = true
        default:
            break
        }
    }
    
    func getUserId() -> String {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserModel.self, from: userData) {
            return user._id
        }
        return ""
    }
    
    @ViewBuilder
    private var trailingContent: some View {
        switch item.type {
        case .navigation:
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        case .toggle(let binding):
            Toggle("", isOn: binding)
                .labelsHidden()
        case .action:
            EmptyView()
        }
    }
}

// MARK: - Setting Item Model

struct SettingItem {
    let icon: String
    let title: String
    let iconColor: String
    let type: SettingItemType
}

enum SettingItemType {
    case navigation
    case toggle(binding: Binding<Bool>)
    case action
}

// MARK: - Preview

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
    }
}
