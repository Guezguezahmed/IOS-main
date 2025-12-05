//
// StaffModels.swift
// IosDam
//
// Data models for Staff management matching Android backend schema

import Foundation

// MARK: - Staff Role Enum

enum StaffRole: String, Codable, CaseIterable {
    case COACH = "COACH"
    case ASSISTANT_COACH = "ASSISTANT_COACH"
    case REFEREE = "REFEREE"
    case MEDIC = "MEDIC"
    case MANAGER = "MANAGER"
}

// MARK: - Staff Model

struct Staff: Codable, Identifiable {
    let _id: String
    let id_user: String
    let id_academie: String
    let role: StaffRole
    let hire_date: String
    let is_active: Bool
    let certifications: [String]
    let experience_years: Int
    let createdAt: String?
    let updatedAt: String?
    
    var id: String { _id }
    
    init(_id: String, id_user: String, id_academie: String, role: StaffRole,
         hire_date: String, is_active: Bool = true, certifications: [String] = [],
         experience_years: Int = 0, createdAt: String? = nil, updatedAt: String? = nil) {
        self._id = _id
        self.id_user = id_user
        self.id_academie = id_academie
        self.role = role
        self.hire_date = hire_date
        self.is_active = is_active
        self.certifications = certifications
        self.experience_years = experience_years
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Populated Staff (with user details)

struct PopulatedStaff: Codable, Identifiable {
    let _id: String
    let id_user: UserModel
    let id_academie: String
    let role: StaffRole
    let hire_date: String
    let is_active: Bool
    let certifications: [String]
    let experience_years: Int
    
    var id: String { _id }
}

// MARK: - Request DTOs

struct CreateStaffRequest: Codable {
    let id_user: String
    let id_academie: String
    let role: StaffRole
    let hire_date: String
    let certifications: [String]?
    let experience_years: Int?
}

struct UpdateStaffRequest: Codable {
    let role: StaffRole?
    let is_active: Bool?
    let certifications: [String]?
    let experience_years: Int?
}

// MARK: - API Response Wrappers

struct StaffResponse: Codable {
    let staff: Staff
}

struct StaffListResponse: Codable {
    let staff: [PopulatedStaff]
}
