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
    let addresstype: String
    let name: JSONNull?
    let displayName: String
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
    let houseNumber, road, cityDistrict, city: String
    let state, iso31662Lvl4, postcode, country: String
    let countryCode: String

    enum CodingKeys: String, CodingKey {
        case houseNumber = "house_number"
        case road
        case cityDistrict = "city_district"
        case city, state
        case iso31662Lvl4 = "ISO3166-2-lvl4"
        case postcode, country
        case countryCode = "country_code"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
