// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let geocoderModel = try? JSONDecoder().decode(GeocoderModel.self, from: jsonData)

import Foundation

// MARK: - GeocoderModel
struct GeocoderModel: Codable {
    let placeID: Int
    let licence, osmType: String
    let osmID: Int
    let lat, lon: String
    let placeRank: Int
    let category, type: String
    let importance: Double
    let addresstype, name, displayName: String?
    let address: Address
    let boundingbox: [String]
    
    enum CodingKeys: String, CodingKey {
        case placeID = "place_id"
        case licence
        case osmType = "osm_type"
        case osmID = "osm_id"
        case lat, lon
        case placeRank = "place_rank"
        case category, type, importance, addresstype, name
        case displayName = "display_name"
        case address, boundingbox
    }
}

// MARK: - Address
struct Address: Codable {
    let building, houseNumber, road, city: String?
    let county, state, iso31662Lvl4, postcode: String?
    let country, countryCode: String?
    
    enum CodingKeys: String, CodingKey {
        case building
        case houseNumber = "house_number"
        case road, city, county, state
        case iso31662Lvl4 = "ISO3166-2-lvl4"
        case postcode, country
        case countryCode = "country_code"
    }
}
