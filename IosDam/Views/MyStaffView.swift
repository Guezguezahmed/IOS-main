//
//  MyStaffView.swift
//  IosDam
//
//  Staff Management View - Xcode 12.3 Compatible
//

import SwiftUI

struct MyStaffView: View {
    @State private var staffMembers: [PopulatedStaff] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showingAddStaff: Bool = false
    @State private var selectedRole: StaffRole? = nil
    @State private var refreshTrigger: Bool = false
    
    var body: some View {
        NavigationView {
            contentView
                .navigationBarTitle("My Staff", displayMode: .large)
                .navigationBarItems(trailing: addButton)
        }
        .onAppear {
            loadStaff()
        }
        .sheet(isPresented: $showingAddStaff) {
            AddStaffView(onStaffAdded: {
                loadStaff()
            })
        }
    }
    
    private var contentView: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading staff...")
            } else if let error = errorMessage {
               errorView(message: error)
            } else if staffMembers.isEmpty {
                emptyStateView
            } else {
                staffListView
            }
        }
    }
    
    private var addButton: some View {
        Button(action: {
            showingAddStaff = true
        }) {
            Image(systemName: "plus")
        }
    }
    
    private var staffListView: some View {
        List {
            filterSection
            
            ForEach(filteredStaff) { staff in
                StaffRowView(staff: staff, onDelete: {
                    deleteStaff(staff)
                }, onEdit: {
                    // Edit functionality can be added as a sheet
                })
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private var filterSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(title: "All", isSelected: selectedRole == nil) {
                        selectedRole = nil
                    }
                    
                    ForEach(StaffRole.allCases, id: \.self) { role in
                        FilterChip(title: role.rawValue, isSelected: selectedRole == role) {
                            selectedRole = role
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var filteredStaff: [PopulatedStaff] {
        if let role = selectedRole {
            return staffMembers.filter { $0.role == role }
        }
        return staffMembers
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Staff Members")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Add staff members to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button(action: {
                showingAddStaff = true
            }) {
                Text("Add Staff")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                loadStaff()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private func loadStaff() {
        guard let userData = UserDefaults.standard.data(forKey: "currentUser"),
              let user = try? JSONDecoder().decode(UserModel.self, from: userData),
              let academieId = user.academieId else {
            errorMessage = "No academie found for user"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        APIService.getAllStaff(academieId: academieId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let staff):
                    staffMembers = staff
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func deleteStaff(_ staff: PopulatedStaff) {
        APIService.deleteStaff(staffId: staff._id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    staffMembers.removeAll { $0._id == staff._id }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Staff Row View

struct StaffRowView: View {
    let staff: PopulatedStaff
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(roleColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(staff.id_user.prenom.prefix(1)))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(staff.id_user.prenom) \(staff.id_user.nom)")
                    .font(.headline)
                
                HStack {
                    roleBadge
                    
                    if !staff.is_active {
                        Text("Inactive")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                    }
                }
                
                if staff.experience_years > 0 {
                    Text("\(staff.experience_years) years experience")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var roleColor: Color {
        switch staff.role {
        case .COACH:
            return Color.blue
        case .ASSISTANT_COACH:
            return Color.blue.opacity(0.7)
        case .REFEREE:
            return Color.green
        case .MEDIC:
            return Color.red
        case .MANAGER:
            return Color.purple
        }
    }
    
    private var roleBadge: some View {
        Text(staff.role.rawValue.replacingOccurrences(of: "_", with: " "))
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(roleColor.opacity(0.2))
            .foregroundColor(roleColor)
            .cornerRadius(4)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Add Staff View

struct AddStaffView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedUserId: String = ""
    @State private var selectedRole: StaffRole = .COACH
    @State private var hireDate: Date = Date()
    @State private var certifications: String = ""
    @State private var experienceYears: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    
    let onStaffAdded: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Staff Information")) {
                    TextField("User ID (for now)", text: $selectedUserId)
                        .autocapitalization(.none)
                    
                    Picker("Role", selection: $selectedRole) {
                        ForEach(StaffRole.allCases, id: \.self) { role in
                            Text(role.rawValue.replacingOccurrences(of: "_", with: " "))
                                .tag(role)
                        }
                    }
                    
                    DatePicker("Hire Date", selection: $hireDate, displayedComponents: .date)
                    
                    TextField("Experience Years", text: $experienceYears)
                        .keyboardType(.numberPad)
                    
                    TextField("Certifications (comma separated)", text: $certifications)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: submitStaff) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Add Staff Member")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(selectedUserId.isEmpty || isSubmitting)
                }
            }
            .navigationBarTitle("Add Staff", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func submitStaff() {
        guard let userData = UserDefaults.standard.data(forKey: "currentUser"),
              let user = try? JSONDecoder().decode(UserModel.self, from: userData),
              let academieId = user.academieId else {
            errorMessage = "No academie found"
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        let dateFormatter = ISO8601DateFormatter()
        let hireDateString = dateFormatter.string(from: hireDate)
        
        let certArray = certifications
            .split(separator: ",")
            .map { String($0.trimmingCharacters(in: .whitespaces)) }
            .filter { !$0.isEmpty }
        
        let expYears = Int(experienceYears) ?? 0
        
        let staffData = CreateStaffRequest(
            id_user: selectedUserId,
            id_academie: academieId,
            role: selectedRole,
            hire_date: hireDateString,
            certifications: certArray.isEmpty ? nil : certArray,
            experience_years: expYears > 0 ? expYears : nil
        )
        
        APIService.createStaff(staffData: staffData) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    presentationMode.wrappedValue.dismiss()
                    onStaffAdded()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Preview

struct MyStaffView_Previews: PreviewProvider {
    static var previews: some View {
        MyStaffView()
    }
}
