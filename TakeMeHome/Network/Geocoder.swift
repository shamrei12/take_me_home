
import Foundation
import OpenCageSDK
//
//protocol Geocoder {
//    var adress: String { get set }
//    func adressToСoordinates(adress: String) -> (Double, Double)
//    func coordinatesToAdress(coordinates: (Double, Double)) -> String
//}
class GeocoderModel {
    var adress: String = ""
    let ocSDK :OCSDK = OCSDK(apiKey: "6fdde9142f9648378e017befaec8f44c")
    func adressToСoordinates(adress: String, completion: @escaping (Double, Double) -> Void) {
        
        ocSDK.forwardGeocode(address: adress, withAnnotations: true) { (response, success, error) in
            if success {
                print(response.locations.first?.latitude ?? 0.0)
                completion (Double(truncating: response.locations.first?.latitude ?? 0.0),
                            Double(truncating: response.locations.first?.longitude ?? 0.0))
            } else {
                print("Error")
            }
        }
    }
    
    func coordinatesToAdress(coordinates: (Double, Double), completion: @escaping (String) -> Void) {
        
        ocSDK.reverseGeocode(latitude: NSNumber(value: coordinates.0), longitude: NSNumber(value: coordinates.1), withAnnotations: true) { (response, success, error) in
            if success {
                print(response.locations.first?.formattedAddress ?? "")
                completion(response.locations.first?.formattedAddress ?? "")
            } else {
                print("Error")
            }
        }
    }
}
