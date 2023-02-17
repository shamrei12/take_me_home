//
//  FirebaseData.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 15.02.23.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage

protocol FirebaseProtocol {
//    func save(posts: [AdvertProtocol])
    //    func load() -> [AdvertProtocol]
}

class FirebaseData: FirebaseProtocol {

    
    //
    //    func load(completion: @escaping ([String:String]) -> Void) {
    //            let ref = Database.database().reference().child("postsList")
    //        }
    
    func load(completion: @escaping ([AdvertProtocol]) -> Void) {
        var resultMass: [AdvertProtocol] = []
        let ref = Database.database().reference().child("posts")
        ref.observe(.value) { snap in
            if let snapshots = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    if let post = snap.value as? Dictionary<String,String>  {
                        resultMass.append(AdvertPost(linkImage: post["listLinks"] ?? "", typePost: post["typePost"] ?? "", breed: post["breed"] ?? "", postName: post["postName"] ?? "", descriptionName: post["description"] ?? "", typePet: post["typePet"] ?? "", oldPet: post["oldPet"] ?? "", lostAdress: post["lostAdress"] ?? "", curentDate: post["curentDate"] ?? ""))
                    }
                }
                completion(resultMass)
            }
        }
    }
    
    func saveImage(_ stroage: Data, completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("postImages")

            storageRef.putData(stroage) { (_, err) in
                guard err == nil else {
                    print("error")
                    return
                }
                storageRef.downloadURL { (url, err) in
                    guard let url = url, err == nil else {
                        print("error")
                        return
                    }
                    let urlString = url.absoluteString
                    completion(urlString)
                }
            }
        }
    
    func save(posts: [AdvertProtocol], stroage: Data) {
        let ref = Database.database().reference().child("posts")
        saveImage(stroage) { data in
            ref.getData { (err, snap) in
                ref.child("\(snap!.childrenCount + 1)").setValue(["postName": posts.first?.postName, "description": posts.first?.descriptionName, "typePet": posts.first?.typePet, "oldPet": posts.first?.oldPet, "lostAdress": posts.first?.lostAdress, "curentDate": posts.first?.curentDate, "breed": posts.first?.breed, "typePost": posts.first?.typePost, "listLinks": data])
            }
        }

    }
}


