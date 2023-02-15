import Foundation


protocol AdvertProtocol {
    var postName: String { get set }
    var descriptionName: String { get set }
    var typePet: String { get set }
    var oldPet: String { get set }
    var lostAdress: String { get set }
    var curentDate: String { get set }
    var breed: String { get set }
    var typePost: String { get set }
}

struct AdvertPost: AdvertProtocol {
    var typePost: String
    var breed: String
    var postName: String
    var descriptionName: String
    var typePet: String
    var oldPet: String
    var lostAdress: String
    var curentDate: String
}
