//
// CreateStadiumView.swift
// IosDam
//
// Create new stadium with GPS coordinates

import SwiftUI
import CoreLocation
import MapKit

struct CreateStadiumView: View {
    @Environment(\.presentationMode) var presentationMode
    let onStadiumCreated: () -> Void
    
    @State private var stadiumName = ""
    @State private var locationVerbal = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var capacity = ""
    @State private var numberOfFields = ""
    @State private var fieldNames: [String] = [""]
    @State private var hasLights = false
    @State private var selectedAmenities: Set<String> = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showLocationPicker = false
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @State private var pickedLocationName = ""
    
    let availableAmenities = ["Parking", "Restrooms", "Changing Rooms", "Showers", "Cafeteria", "Medical Room", "VIP Boxes", "Press Room"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            
                            Text("Create Stadium")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding(.top, 20)
                        
                        // Form
                        VStack(spacing: 15) {
                            // Stadium Name
                            FormField(title: "Stadium Name", placeholder: "Enter name", text: $stadiumName)
                            
                            // Location (Verbal)
                            FormField(title: "Location Description", placeholder: "e.g., Downtown, Near City Hall", text: $locationVerbal)
                            
                            // GPS Coordinates
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("GPS Coordinates")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showLocationPicker = true
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "mappin.and.ellipse")
                                            Text("Pick on Map")
                                        }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                    }
                                }
                                
                                HStack(spacing: 10) {
                                    TextField("Latitude", text: $latitude)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(10)
                                    
                                    TextField("Longitude", text: $longitude)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(10)
                                }
                                
                                if !pickedLocationName.isEmpty {
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text(pickedLocationName)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Capacity
                            FormField(title: "Capacity", placeholder: "Number of spectators", text: $capacity, keyboardType: .numberPad)
                            
                            // Number of Fields
                            FormField(title: "Number of Fields", placeholder: "e.g., 2", text: $numberOfFields, keyboardType: .numberPad)
                            
                            // Field Names
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Field Names")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Button(action: { fieldNames.append("") }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(.horizontal)
                                
                                ForEach(fieldNames.indices, id: \.self) { index in
                                    HStack {
                                        TextField("Field \(index + 1) name", text: $fieldNames[index])
                                            .padding()
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(10)
                                        
                                        if fieldNames.count > 1 {
                                            Button(action: { fieldNames.remove(at: index) }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Has Lights Toggle
                            HStack {
                                Text("Stadium Lights")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                Spacer()
                                Toggle("", isOn: $hasLights)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: .green))
                            }
                            .padding(.horizontal)
                            
                            // Amenities
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Amenities")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    ForEach(availableAmenities, id: \.self) { amenity in
                                        AmenityButton(
                                            title: amenity,
                                            isSelected: selectedAmenities.contains(amenity),
                                            action: {
                                                if selectedAmenities.contains(amenity) {
                                                    selectedAmenities.remove(amenity)
                                                } else {
                                                    selectedAmenities.insert(amenity)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Create Button
                        Button(action: createStadium) {
                            HStack {
                                Spacer()
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create Stadium")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(isFormValid ? Color.green : Color.gray.opacity(0.5))
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                        }
                        .disabled(!isFormValid || isLoading)
                        .padding(.vertical, 20)
                    }
                }
                
                if isLoading {
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                    ProgressView("Creating stadium...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
            .navigationBarTitle("New Stadium", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showLocationPicker, onDismiss: {
                if let coord = selectedCoordinate {
                    latitude = String(format: "%.6f", coord.latitude)
                    longitude = String(format: "%.6f", coord.longitude)
                    if locationVerbal.isEmpty && !pickedLocationName.isEmpty {
                        locationVerbal = pickedLocationName
                    }
                }
            }) {
                LocationPickerView(
                    selectedCoordinate: $selectedCoordinate,
                    locationName: $pickedLocationName
                )
    
            }
        }
    }

    var isFormValid: Bool {
        !stadiumName.isEmpty &&
        !locationVerbal.isEmpty &&
        !latitude.isEmpty &&
        !longitude.isEmpty &&
        !capacity.isEmpty &&
        !numberOfFields.isEmpty &&
        Double(latitude) != nil &&
        Double(longitude) != nil &&
        Int(capacity) != nil &&
        Int(numberOfFields) != nil
    }
    
    func createStadium() {
        guard isFormValid else { return }
        
        // Get current user
        guard let userData = UserDefaults.standard.data(forKey: "currentUser"),
              let currentUser = try? JSONDecoder().decode(UserModel.self, from: userData) else {
            alertMessage = "User not found. Please log in again."
            showAlert = true
            return
        }
        
        // Use user's _id as the academy ID
        let academyId = currentUser._id
        
        guard let lat = Double(latitude),
              let lon = Double(longitude),
              let cap = Int(capacity),
              let numFields = Int(numberOfFields) else {
            alertMessage = "Please check your input values."
            showAlert = true
            return
        }
        
        isLoading = true
        
        let coordinates = Coordinates(latitude: lat, longitude: lon)
        let nonEmptyFieldNames = fieldNames.filter { !$0.isEmpty }
        
        let stadiumRequest = CreateTerrainRequest(
            id_academie: academyId, // Updated to use currentUser._id
            name: stadiumName,
            location_verbal: locationVerbal,
            coordinates: coordinates,
            capacity: cap,
            number_of_fields: numFields,
            field_names: nonEmptyFieldNames.isEmpty ? nil : nonEmptyFieldNames,
            has_lights: hasLights,
            amenities: selectedAmenities.isEmpty ? nil : Array(selectedAmenities),
            is_available: true
        )
        
        APIService.createStadium(stadiumData: stadiumRequest) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    alertMessage = "Stadium created successfully!"
                    showAlert = true
                    onStadiumCreated()
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

// MARK: - Form Field Component

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

// MARK: - Amenity Button

struct AmenityButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .green : .gray)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - Preview

struct CreateStadiumView_Previews: PreviewProvider {
    static var previews: some View {
        CreateStadiumView(onStadiumCreated: {})
    }
}
