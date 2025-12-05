//
// EventsView.swift
// IosDam
//
// Events/Tournaments list screen with search and filtering

import SwiftUI

struct EventsView: View {
    var body: some View {
        // EventsView now just shows the list since NavigationLink handles navigation
        EventsListView(onEventClick: { event in
            // Navigation is handled by NavigationLink in EventCardView
            print("🎯 Event tapped: \(event.tournamentName)")
        })
    }
}

// MARK: - Events List View

struct EventsListView: View {
    let onEventClick: (Tournament) -> Void
    
    @State private var selectedType = "All Events"
    @State private var searchQuery = ""
    @State private var events: [Tournament] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var currentUserId: String? = nil
    @State private var didLoadData = false // ✅ Prevents repeated onAppear calls
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome Back! ⚽")
                            .font(.system(size: 28, weight: .bold))
                        Text("Find your next match")
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                        
                    // Stats Cards
                    HStack(spacing: 8) {
                        StatCardView(value: "12", label: "Wins", color: Color.green)
                        StatCardView(value: "8", label: "Active", color: Color.blue)
                        StatCardView(value: "75%", label: "Win Rate", color: Color.orange)
                    }
                    .padding(.horizontal)
                        
                    // Search Bar
                    SearchBarView(query: $searchQuery)
                        .padding(.horizontal)
                        
                    // Category Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tabData, id: \.label) { tab in
                                TabChipView(tab: tab, selectedType: $selectedType)
                            }
                        }
                        .padding(.horizontal)
                    }
                        
                    // Events List
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(selectedType) (\(filteredEvents.count))")
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.horizontal)
                            
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if let error = errorMessage {
                            Text(error)
                                .foregroundColor(Color.red)
                                .padding()
                        } else if filteredEvents.isEmpty {
                            Text("No events found.")
                                .foregroundColor(Color.gray)
                                .padding()
                        } else {
                            ForEach(filteredEvents) { event in
                                EventCardView(event: event, onClick: {
                                    onEventClick(event)
                                })
                                .padding(.horizontal)
                            }
                        }
                    }
                        
                    Spacer(minLength: 30)
                }
            }
        }
        .onAppear {
            if !didLoadData {
                loadEvents()
                didLoadData = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var tabData: [TabData] {
        let categories = ["All Events", "My Events", "Tournament", "League"]
        return categories.map { category in
            let count: Int
            switch category {
            case "All Events":
                count = events.count
            case "My Events":
                count = events.filter { $0.idOrganisateur?.id == currentUserId }.count
            case "Tournament", "League":
                count = events.filter { $0.type == category }.count
            default:
                count = 0
            }
            return TabData(label: category, count: count, isSelected: category == selectedType)
        }
    }
    
    var filteredEvents: [Tournament] {
        let tabFiltered: [Tournament]
        switch selectedType {
        case "All Events":
            tabFiltered = events
        case "My Events":
            tabFiltered = events.filter { $0.idOrganisateur?.id == currentUserId }
        default:
            tabFiltered = events.filter { $0.type == selectedType }
        }
            
        if searchQuery.isEmpty {
            return tabFiltered
        } else {
            let query = searchQuery.lowercased()
            return tabFiltered.filter {
                $0.tournamentName.lowercased().contains(query) ||
                $0.stadium.lowercased().contains(query) ||
                $0.nom.lowercased().contains(query)
            }
        }
    }
    
    // MARK: - Data Loading
    
    func loadEvents() {
        print("🔵 Loading events...")
        isLoading = true
        errorMessage = nil
            
        // Get current user
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
            let user = try? JSONDecoder().decode(UserModel.self, from: userData) {
            currentUserId = user._id
            print("✅ Current user ID: \(user._id)")
        } else {
            print("⚠️ No current user found")
        }
            
        APIService.getTournaments { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let tournaments):
                    print("✅ Loaded \(tournaments.count) tournaments")
                    if tournaments.isEmpty {
                        print("⚠️ Backend returned empty array")
                    } else {
                        print("📋 Tournament names: \(tournaments.map { $0.tournamentName })")
                    }
                    events = tournaments
                case .failure(let error):
                    print("❌ Error loading tournaments: \(error)")
                    print("❌ Error details: \(error.localizedDescription)")
                    errorMessage = "Failed to load events: \(error.localizedDescription)"
                }
            }
        }
    }
}


// MARK: - Preview

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
