//
//  GeocoderModel.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 1.04.23.
//

import Foundation


protocol GeocoderProtocol {
    var country: String { get set }
    var city: String { get set }
    var street: String { get set }
    var houseNumber: String { get set }
    var buildingNumber: String { get set }
}

struct Geocoder: GeocoderProtocol {
    var country: String
    var city: String
    var street: String
    var houseNumber: String
    var buildingNumber: String
}
