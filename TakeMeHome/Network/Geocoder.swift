import Foundation
import Alamofire

class SessionManager {
    static var shared: SessionManager = {
        let instance = SessionManager()
        return instance
    }()
    
    private init() {}
    
    func countryRequest(common: (Double, Double), dataResponse: @escaping (GeocoderModel) -> Void) {
        let urlString = "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=\(common.0)&lon=\(common.1)&accept-language=ru"
        AF.request(urlString).responseDecodable(of: GeocoderModel.self) { response in
            switch response.result {
            case .success(let model):
                DispatchQueue.main.async {
                    dataResponse(model)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
