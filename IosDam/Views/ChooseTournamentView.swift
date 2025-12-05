//
//  ChooseTournamentView.swift
//  IosDam
//
//  Created by macbook on 1/12/2025.
//

import SwiftUI

// MARK: - Tournament Type Options

enum TournamentFormat: String, CaseIterable {
    case knockout = "Knockout Tournament"
    case league = "League"
    case quickMatch = "Quick Match"
    
    var description: String {
        switch self {
        case .knockout:
            return "Single elimination bracket"
        case .league:
            return "Round-robin format"
        case .quickMatch:
            return "Fast casual game"
        }
    }
    
    var teamRange: String {
        switch self {
        case .knockout:
            return "8-16 teams"
        case .league:
            return "6-12 teams"
        case .quickMatch:
            return "2-10 teams"
        }
    }
    
    var icon: String {
        switch self {
        case .knockout:
            return "star.fill"
        case .league:
            return "flag.fill"
        case .quickMatch:
            return "bolt.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .knockout:
            return Color.purple
        case .league:
            return Color.blue
        case .quickMatch:
            return Color.orange
        }
    }
}

// MARK: - Main View

struct ChooseTournamentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedFormat: TournamentFormat? = nil
    
    // ⭐️ NEW: State to trigger navigation
    @State private var navigateToAddTournament = false
    @State private var showQuickMatchAlert = false
    
    var onContinue: ((TournamentFormat) -> Void)? = nil
    
    var body: some View {
        // ⭐️ NEW: Wrap in NavigationView to enable navigation stack
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                // ⭐️ NEW: Hidden Navigation Link to push to the next screen
                NavigationLink(
                    destination: AddTournement(preselectedType: mapFormatToType(selectedFormat)), // Pass selected type
                    isActive: $navigateToAddTournament
                ) {
                    EmptyView()
                }
                
                VStack(spacing: 0) {
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * 0.5, height: 4)
                        }
                    }
                    .frame(height: 4)
                    
                    // Content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Header
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Choose Tournament Type")
                                    .font(.system(size: 24, weight: .bold))
                                Text("Select the format that suits your event")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.top, 24)
                            
                            // Tournament Type Cards
                            VStack(spacing: 16) {
                                ForEach(TournamentFormat.allCases, id: \.self) { format in
                                    TournamentTypeCard(
                                        format: format,
                                        isSelected: selectedFormat == format
                                    ) {
                                        withAnimation(.spring()) {
                                            selectedFormat = format
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                    
                    // Continue Button
                    Button(action: {
                        if let format = selectedFormat {
                            // Check if Quick Match is selected
                            if format == .quickMatch {
                                showQuickMatchAlert = true
                            } else {
                                // Call optional closure if needed
                                onContinue?(format)
                                // ⭐️ NEW: Trigger navigation
                                navigateToAddTournament = true
                            }
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(selectedFormat == nil ? .secondary : .white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedFormat == nil ? Color(UIColor.systemGray5) : Color(red: 0.4, green: 0.7, blue: 0.6))
                            .cornerRadius(12)
                    }
                    .disabled(selectedFormat == nil)
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        // Ensure full screen style on iPad if needed
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showQuickMatchAlert) {
            Alert(
                title: Text("Coming Soon"),
                message: Text("Quick Match is not featured yet. Please select Knockout Tournament or League."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Helper Function
    
    /// Maps TournamentFormat to CoupeType for AddTournement
    private func mapFormatToType(_ format: TournamentFormat?) -> CoupeType? {
        guard let format = format else { return nil }
        switch format {
        case .knockout:
            return .TOURNAMENT
        case .league:
            return .LEAGUE
        case .quickMatch:
            return nil // Not implemented yet
        }
    }
}

// MARK: - Tournament Type Card Component

struct TournamentTypeCard: View {
    let format: TournamentFormat
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon Circle
                ZStack {
                    Circle()
                        .fill(format.iconColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: format.icon)
                        .font(.system(size: 24))
                        .foregroundColor(format.iconColor)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(format.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text(format.teamRange)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(red: 0.9, green: 0.95, blue: 0.93))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct ChooseTournamentView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseTournamentView(onContinue: { format in
            print("Selected: \(format.rawValue)")
        })
    }
}
