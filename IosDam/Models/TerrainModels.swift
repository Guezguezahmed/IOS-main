//
// TerrainModels.swift
// IosDam
//
// Data models for Stadium (Terrain) management matching Android backend schema

import Foundation

// MARK: - Coordinates

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}

// MARK: - Terrain Model

struct Terrain: Codable, Identifiable {
    let _id: String
    let id_academie: String
    let name: String
    let location_verbal: String
    let coordinates: Coordinates
    let capacity: Int
    let number_of_fields: Int
    let field_names: [String]
    let has_lights: Bool
    let amenities: [String]
    let is_available: Bool
    let createdAt: String?
    let updatedAt: String?
    
    var id: String { _id }
    
    // Default values for optional arrays
    init(_id: String, id_academie: String, name: String, location_verbal: String,
         coordinates: Coordinates, capacity: Int, number_of_fields: Int,
         field_names: [String] = [], has_lights: Bool = false,
         amenities: [String] = [], is_available: Bool = true,
         createdAt: String? = nil, updatedAt: String? = nil) {
        self._id = _id
        self.id_academie = id_academie
        self.name = name
        self.location_verbal = location_verbal
        self.coordinates = coordinates
        self.capacity = capacity
        self.number_of_fields = number_of_fields
        self.field_names = field_names
        self.has_lights = has_lights
        self.amenities = amenities
        self.is_available = is_available
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Request DTOs

struct CreateTerrainRequest: Codable {
    let id_academie: String
    let name: String
    let location_verbal: String
    let coordinates: Coordinates
    let capacity: Int
    let number_of_fields: Int
    let field_names: [String]?
    let has_lights: Bool?
    let amenities: [String]?
    let is_available: Bool?
    
    init(id_academie: String, name: String, location_verbal: String,
         coordinates: Coordinates, capacity: Int, number_of_fields: Int,
         field_names: [String]? = nil, has_lights: Bool? = false,
         amenities: [String]? = nil, is_available: Bool? = true) {
        self.id_academie = id_academie
        self.name = name
        self.location_verbal = location_verbal
        self.coordinates = coordinates
        self.capacity = capacity
        self.number_of_fields = number_of_fields
        self.field_names = field_names
        self.has_lights = has_lights
        self.amenities = amenities
        self.is_available = is_available
    }
}

struct UpdateTerrainRequest: Codable {
    let name: String?
    let location_verbal: String?
    let coordinates: Coordinates?
    let capacity: Int?
    let number_of_fields: Int?
    let field_names: [String]?
    let has_lights: Bool?
    let amenities: [String]?
    let is_available: Bool?
}

// MARK: - API Response Wrappers

struct TerrainResponse: Codable {
    let terrain: Terrain
}

struct TerrainListResponse: Codable {
    let terrains: [Terrain]
}
