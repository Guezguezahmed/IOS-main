//
// MapView.swift
// IosDam
//
// Reusable map component for displaying stadium locations

import SwiftUI
import MapKit

struct StadiumAnnotation: Identifiable {
    let id = UUID()
    let terrain: Terrain
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: terrain.coordinates.latitude,
            longitude: terrain.coordinates.longitude
        )
    }
}

struct StadiumMapView: View {
    let stadiums: [Terrain]
    @State private var region: MKCoordinateRegion
    @State private var selectedStadium: Terrain?
    
    var onStadiumTap: ((Terrain) -> Void)?
    
    init(stadiums: [Terrain], onStadiumTap: ((Terrain) -> Void)? = nil) {
        self.stadiums = stadiums
        self.onStadiumTap = onStadiumTap
        
        // Calculate initial region to show all stadiums
        if let firstStadium = stadiums.first {
            let center = CLLocationCoordinate2D(
                latitude: firstStadium.coordinates.latitude,
                longitude: firstStadium.coordinates.longitude
            )
            _region = State(initialValue: MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        } else {
            // Default to Tunis if no stadiums
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 36.8065, longitude: 10.1815),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            ))
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    Button(action: {
                        selectedStadium = annotation.terrain
                        onStadiumTap?(annotation.terrain)
                    }) {
                        VStack(spacing: 0) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                            
                            // Pin tail
                            Triangle()
                                .fill(Color.blue)
                                .frame(width: 12, height: 8)
                                .offset(y: -1)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // Selected stadium card
            if let stadium = selectedStadium {
                StadiumInfoCard(stadium: stadium) {
                    selectedStadium = nil
                }
                .padding()
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            adjustRegionToFitStadiums()
        }
    }
    
    var annotations: [StadiumAnnotation] {
        stadiums.map { StadiumAnnotation(terrain: $0) }
    }
    
    func adjustRegionToFitStadiums() {
        guard !stadiums.isEmpty else { return }
        
        var minLat = stadiums[0].coordinates.latitude
        var maxLat = stadiums[0].coordinates.latitude
        var minLon = stadiums[0].coordinates.longitude
        var maxLon = stadiums[0].coordinates.longitude
        
        for stadium in stadiums {
            minLat = min(minLat, stadium.coordinates.latitude)
            maxLat = max(maxLat, stadium.coordinates.latitude)
            minLon = min(minLon, stadium.coordinates.longitude)
            maxLon = max(maxLon, stadium.coordinates.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.5, 0.05),
            longitudeDelta: max((maxLon - minLon) * 1.5, 0.05)
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - Stadium Info Card

struct StadiumInfoCard: View {
    let stadium: Terrain
    let onClose: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stadium.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(stadium.location_verbal)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    Label("\(stadium.capacity)", systemImage: "person.3.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    
                    if stadium.has_lights {
                        Label("Lights", systemImage: "lightbulb.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 24))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 8)
    }
}

// MARK: - Triangle Shape for Pin

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
