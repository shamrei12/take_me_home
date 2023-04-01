//
//  GeocoderModel.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 1.04.23.
//

import Foundation

// MARK: - GeocoderModel
struct GeocoderModel: Codable {
    let type: String
    let features: [Feature]
}

struct Feature: Codable {
    let type: String
    let properties: Properties
    let geometry: Geometry
}

struct Properties: Codable {
    let placeID: Int
    let licence: String?
    let osmType: String
    let osmID: Int
    let lat: String?
    let lon: String?
    let placeRank: Int
    let category: String
    let type: String
    let importance: Double
    let addresstype: String
    let name: String
    let displayName: String
    let address: Address
    
    enum CodingKeys: String, CodingKey {
        case placeID = "place_id"
        case licence
        case osmType = "osm_type"
        case osmID = "osm_id"
        case lat, lon
        case placeRank = "place_rank"
        case category, type, importance, addresstype, name
        case displayName = "display_name"
        case address
    }
}

struct Address: Codable {
    let building: String?
    let houseNumber: String?
    let road: String?
    let city: String?
    let county: String?
    let state: String?
    let iso31662Lvl4: String?
    let postcode: String?
    let country: String?
    let countryCode: String?
    
    enum CodingKeys: String, CodingKey {
        case building
        case houseNumber = "house_number"
        case road, city, county, state
        case iso31662Lvl4 = "ISO3166-2-lvl4"
        case postcode, country
        case countryCode = "country_code"
    }
}

struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
}
