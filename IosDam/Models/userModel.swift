import Foundation
import SwiftUI

class UserModel: ObservableObject, Codable {
    @Published var _id: String
    @Published var prenom: String
    @Published var nom: String
    @Published var email: String
    @Published var age: String
    @Published var tel: Int
    @Published var role: String
    @Published var isVerified: Bool
    @Published var picture: String?     // Base64 ou URL
    @Published var academieId: String?   // FIX 1: Added missing academieId
    
    // Computed property for full name
    var fullName: String {
        "\(prenom) \(nom)"
    }

    enum CodingKeys: CodingKey {
        case _id, prenom, nom, email, age, tel, role, isVerified, picture, academieId
    }

    init(_id: String, prenom: String, nom: String, email: String, age: String, tel: Int, role: String, isVerified: Bool, picture: String?, academieId: String? = nil) {
        self._id = _id
        self.prenom = prenom
        self.nom = nom
        self.email = email
        self.age = age
        self.tel = tel
        self.role = role
        self.isVerified = isVerified
        self.picture = picture
        self.academieId = academieId
    }

    // Codable: Decoding
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(String.self, forKey: ._id)
        prenom = try container.decode(String.self, forKey: .prenom)
        nom = try container.decode(String.self, forKey: .nom)
        email = try container.decode(String.self, forKey: .email)
        age = try container.decode(String.self, forKey: .age)
        tel = try container.decode(Int.self, forKey: .tel)
        role = try container.decode(String.self, forKey: .role)
        isVerified = try container.decode(Bool.self, forKey: .isVerified)
        picture = try container.decodeIfPresent(String.self, forKey: .picture)
        // FIX 1: Decode optional academieId
        academieId = try container.decodeIfPresent(String.self, forKey: .academieId)
    }

    // Codable: Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(prenom, forKey: .prenom)
        try container.encode(nom, forKey: .nom)
        try container.encode(email, forKey: .email)
        try container.encode(age, forKey: .age)
        try container.encode(tel, forKey: .tel)
        try container.encode(role, forKey: .role)
        try container.encode(isVerified, forKey: .isVerified)
        try container.encodeIfPresent(picture, forKey: .picture)
        // FIX 1: Encode optional academieId
        try container.encodeIfPresent(academieId, forKey: .academieId)
    }
}
