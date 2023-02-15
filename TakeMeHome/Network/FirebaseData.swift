//
//  FirebaseData.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 15.02.23.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

protocol FirebaseProtocol {
    func save(posts: [AdvertProtocol])
//    func load() -> [AdvertProtocol]
}

class FirebaseData: FirebaseProtocol {
    
//        func load() -> [AdvertProtocol] {
//            <#code#>
//        }
//    
    
    func save(posts: [AdvertProtocol]) {
        let ref = Database.database().reference().child("postsList")
        ref.getData { (err, snap) in
            ref.child("\(snap!.childrenCount + 1)").setValue(["postName": posts.first?.postName, "description": posts.first?.descriptionName, "typePet": posts.first?.typePet, "oldPet": posts.first?.oldPet, "lostAdress": posts.first?.lostAdress, "curentDate": posts.first?.curentDate, "breed": posts.first?.breed, "typePost": posts.first?.typePost])
        }
    }
}
    

