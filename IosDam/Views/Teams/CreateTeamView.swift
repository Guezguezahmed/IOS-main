//
// CreateTeamView.swift
// IosDam
//
// Create new team form

import SwiftUI

struct CreateTeamView: View {
    @Environment(\.presentationMode) var presentationMode
    let onTeamCreated: () -> Void
    
    @State private var teamName = ""
    @State private var selectedCategory: Categorie = .SENIOR
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Create New Team")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 15) {
                        // Team Name
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Team Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            TextField("Enter team name", text: $teamName)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Category")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(Categorie.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(.horizontal)
                        
                        // Info text
                        Text("You can add members and configure the roster after creating the team.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    // Create Button
                    Button(action: createTeam) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Team")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(teamName.isEmpty ? Color.gray.opacity(0.5) : Color.green)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    }
                    .disabled(teamName.isEmpty || isLoading)
                    .padding(.bottom, 40)
                }
                
                if isLoading {
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                    ProgressView("Creating team...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
            .navigationBarTitle("New Team", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func createTeam() {
        guard !teamName.isEmpty else { return }
        
        // Get current user
        guard let userData = UserDefaults.standard.data(forKey: "currentUser"),
              let currentUser = try? JSONDecoder().decode(UserModel.self, from: userData) else {
            alertMessage = "User not found. Please log in again."
            showAlert = true
            return
        }
        
        // Use user's _id as the academy ID
        let academyId = currentUser._id
        
        isLoading = true
        
        let teamRequest = CreateEquipeRequest(
            nom: teamName,
            id_academie: academyId,
            categorie: selectedCategory
        )
        
        APIService.createTeam(teamData: teamRequest) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    alertMessage = "Team created successfully!"
                    showAlert = true
                    onTeamCreated()
                    // Delay dismissal to show success message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Preview

struct CreateTeamView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTeamView(onTeamCreated: {})
    }
}
