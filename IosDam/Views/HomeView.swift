import SwiftUI

struct HomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var isLoggedOut = false
    @AppStorage("user_role") var currentUserRole: String = "OWNER"
    @AppStorage("user_prenom") var appStoragePrenom: String = "Loading..."
    @AppStorage("user_nom") var appStorageNom: String = "Loading..."

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Main Content - TabView
                    TabView(selection: $selectedTab) {
                        // Home Feed
                        ScrollView {
                            VStack(spacing: 20) {
                                welcomeHeader
                                quickActions
                                Spacer()
                            }
                            .padding()
                        }
                        .tag(0)

                        // Events
                        EventsView()
                            .tag(1)

                        // Add Tournament - OWNER only, empty for others
                        if currentUserRole == "OWNER" {
                            ChooseTournamentView()
                                .tag(2)
                        } else {
                            // Empty placeholder to maintain tab index
                            Color.clear
                                .tag(2)
                        }

                        // Social
                        SocialsChatView()
                            .tag(3)

                        // Profile
                        ProfileView()
                            .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                    // MARK: - Bottom Navbar
                    HStack {
                        navButton(icon: "house.fill", label: "Home", index: 0)
                        Spacer()
                        navButton(icon: "calendar", label: "Events", index: 1)
                        Spacer()
                        
                        // Add button - OWNER ONLY
                        if currentUserRole == "OWNER" {
                            navButton(icon: "plus.circle.fill", label: "Add", index: 2)
                            Spacer()
                        }
                        
                        navButton(icon: "person.2.fill", label: "Social", index: 3)
                        Spacer()
                        navButton(icon: "person.crop.circle", label: "Profile", index: 4)
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, y: -2)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView()
                .navigationBarHidden(true)
        }
        .onAppear {
            loadUserRole()
        }
    }

    // MARK: - Bottom Nav Button
    func navButton(icon: String, label: String, index: Int) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(selectedTab == index ? Color.green : Color.gray)

            Text(label)
                .font(.caption)
                .foregroundColor(selectedTab == index ? Color.green : Color.gray)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            selectedTab = index
        }
    }
    
    // MARK: - Load User Role
    
    func loadUserRole() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserModel.self, from: userData) {
            // Save to AppStorage for synchronous access
            UserDefaults.standard.set(user.role, forKey: "user_role")
        }
    }
    
    // MARK: - Welcome Header
    
    var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Welcome Back! 👋")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("\(appStorageNom) \(appStoragePrenom)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Quick Actions
    
    var quickActions: some View {
        VStack(spacing: 15) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // OWNER only sections
            if currentUserRole == "OWNER" {
                NavigationLink(destination: TeamsListView()) {
                    quickActionCard(icon: "person.3.fill", title: "Teams", subtitle: "View and manage teams", color: .green)
                }
                
                NavigationLink(destination: StadiumsListView()) {
                    quickActionCard(icon: "building.2.fill", title: "Stadiums", subtitle: "View and manage stadiums", color: .blue)
                }
                
                NavigationLink(destination: MyStaffView()) {
                    quickActionCard(icon: "person.3.fill", title: "My Staff", subtitle: "Manage coaches and staff", color: .purple)
                }
            }
            
            // Logout button
            Button(action: logout) {
                Text("Logout")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
        }
    }
    
    func quickActionCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // MARK: - Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: "userToken")
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "user_role")  // Clear role
        UserDefaults.standard.set(false, forKey: "rememberMe")
        isLoggedOut = true
    }
}
