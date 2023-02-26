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
    var currentUploadTask: StorageUploadTask?
    
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
                    if let post = snap.value as? Dictionary<String, String>  {
                        resultMass.append(AdvertPost(postId: post["postID"] ?? "", phoneNumber: post["phoneNumber"] ?? "", linkImage: post["listLinks"] ?? "", typePost: post["typePost"] ?? "", breed: post["breed"] ?? "", postName: post["postName"] ?? "", descriptionName: post["description"] ?? "", typePet: post["typePet"] ?? "", oldPet: post["oldPet"] ?? "", lostAdress: post["lostAdress"] ?? "", curentDate: post["curentDate"] ?? ""))
                    }
                }
                completion(resultMass)
            }
        }
    }
    
    func loadComments(id: String, completion: @escaping ([Comments]) -> Void) {
        let ref = Database.database().reference().child("comments").child(id)
        var commentsUser = [Comments]()
        
        ref.observe(.value) { snap in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for idSnap in snapshot {
                    if let comments = idSnap.value as? Dictionary <String, AnyObject> {
                        commentsUser.append(UserComments(name: comments.keys.first as? String ?? "", comment: comments.values.first as? String ?? ""))
                    } else {
                        print("error")
                    }
                    
                }
                completion(commentsUser)
                
            }
        }
        
    }
    
    func getUserName(completion: @escaping (String) -> Void) {
        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("users")
        
        ref.child(userID!).observeSingleEvent(of: .value) { snap in
            let value = snap.value as? Dictionary< String, String>
            let username = value?["name"] ?? ""
            completion(username)
        }
    }
    
    func SaveComment(id: String, key: String, value: String) {
        let ref = Database.database().reference().child("comments")
        let refChild = Database.database().reference().child("comments").child(id)
        //
        //        ref.getData { (err, snap) in
        //            ref.child("\(id)").setValue(["\(snap!.childrenCount + 1)":[key:value]])
        //        }
        
        ref.getData { (errMain, snapMain) in
            refChild.getData { (err, snap) in
                ref.child("\(id)").child("\(snap!.childrenCount + 1)").setValue([key:value])
            }
        }
        
    }
    
    func loadSinglePost (id: String ,completion: @escaping ([AdvertProtocol]) -> Void) {
        var resultMass: [AdvertProtocol] = []
        let ref = Database.database().reference().child("posts").child(id)
        ref.observe(.value) { snap in
            if let snapshots = snap.children.allObjects as? [DataSnapshot] {
                if let post = snap.value as? Dictionary<String, String>  {
                    resultMass.append(AdvertPost(postId: post["postID"] ?? "", phoneNumber: post["phoneNumber"] ?? "", linkImage: post["listLinks"] ?? "", typePost: post["typePost"] ?? "", breed: post["breed"] ?? "", postName: post["postName"] ?? "", descriptionName: post["description"] ?? "", typePet: post["typePet"] ?? "", oldPet: post["oldPet"] ?? "", lostAdress: post["lostAdress"] ?? "", curentDate: post["curentDate"] ?? ""))
                }
                completion(resultMass)
            }
        }
    }
    
    func saveImage(_ storage: [Data],_ userID: String,  completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("postImages")
        //        for data in stroage { dispatchGroup read
        for data in 0...storage.count - 1 {
            storageRef.child("\(userID)_\(data)").putData(storage[data]) { (metadata, err) in
                guard err == nil else {
                    print("error")
                    return
                }
                storageRef.child("\(userID)_\(data)").downloadURL { (url, err) in
                    
                    guard let url = url, err == nil else {
                        print("error")
                        return
                    }
                    let urlString = url.absoluteString
                    completion(urlString)
                }
            }
        }
    }
    
    func save(posts: [AdvertProtocol], stroage: [Data]) {
        let ref = Database.database().reference().child("posts")
        var list = String()
        ref.getData { (err, snap) in
            self.saveImage(stroage, "\(snap!.childrenCount + 1)") { data in
                DispatchQueue.global().async {
                    list += "\(data) "
                    DispatchQueue.main.async {
                        ref.child("\(snap!.childrenCount + 1)").setValue(["postName": posts.first?.postName, "description": posts.first?.descriptionName, "typePet": posts.first?.typePet, "oldPet": posts.first?.oldPet, "lostAdress": posts.first?.lostAdress, "curentDate": posts.first?.curentDate, "breed": posts.first?.breed, "typePost": posts.first?.typePost, "listLinks": list, "phoneNumber": posts.first?.phoneNumber, "postID": "\(snap!.childrenCount + 1)"])
                    }
                }
                
            }
        }
    }
    
}