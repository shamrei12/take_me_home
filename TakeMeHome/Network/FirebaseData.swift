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
    
    func load(completion: @escaping ([AdvertProtocol]) -> Void) {
        var resultMass: [AdvertProtocol] = []
        let ref = Database.database().reference().child("posts")
        ref.observe(.value) { snap in
            resultMass.removeAll()
            if let snapshots = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    if let post = snap.value as? Dictionary<String, String> {
                        resultMass.append(AdvertPost(countComments: post["countComments"] ?? "", postId: post["postID"] ?? "", phoneNumber: post["phoneNumber"] ?? "", linkImage: post["listLinks"] ?? "", typePost: post["typePost"] ?? "", breed: post["breed"] ?? "", postName: post["postName"] ?? "", descriptionName: post["description"] ?? "", typePet: post["typePet"] ?? "", oldPet: post["oldPet"] ?? "", lostAdress: post["lostAdress"] ?? "", curentDate: post["curentDate"] ?? ""))
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
    
    func saveIDPostUser(id: String) {
        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("users").child(userID!)
        
        ref.child("idPosts").getData { (err, snap) in
            ref.child("idPosts").child("\(snap!.childrenCount + 1)").setValue("\(id)")
        }
    }
    
    func loadUserPostsLinks(completion: @escaping (([String]) -> Void)) {
        var list = [String]()
        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("users").child(userID!).child("idPosts")
        
        ref.observe(.value) { snap in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for idPost in snapshot {
                    if idPost.value is String {
                        list.append(idPost.value as! String)
                    }
                    
                }
                completion(list)
            }
        }
    }
    
    func getUserName(completion: @escaping (String) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion("")
            return
        }
        let ref = Database.database().reference().child("users").child(userID)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String: Any], let name = value["name"] as? String {
                completion(name)
            } else {
                completion("")
            }
        } withCancel: { (error) in
            print("Error getting user name: \(error.localizedDescription)")
            completion("")
        }
    }
    
    func SaveComment(id: String, key: String, value: String) {
        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("comments")
        let refChild = Database.database().reference().child("comments").child(id)
        let refPostComments = Database.database().reference().child("posts").child(id)
        ref.getData { (errMain, snapMain) in
            refChild.getData { (err, snap) in
                ref.child("\(id)").child("\(snap!.childrenCount + 1)").setValue([key:value])
                
                refPostComments.child("countComments").setValue("\(snap!.childrenCount + 1)")
            }
        }
    }
    
    func loadSinglePost (id: String ,completion: @escaping ([AdvertProtocol]) -> Void) {
        var resultMass: [AdvertProtocol] = []
        let ref = Database.database().reference().child("posts").child(id)
        ref.observe(.value) { snap in
            if let snapshots = snap.children.allObjects as? [DataSnapshot] {
                if let post = snap.value as? Dictionary<String, String>  {
                    resultMass.append(AdvertPost(countComments: post["countComments"] ?? "", postId: post["postID"] ?? "", phoneNumber: post["phoneNumber"] ?? "", linkImage: post["listLinks"] ?? "", typePost: post["typePost"] ?? "", breed: post["breed"] ?? "", postName: post["postName"] ?? "", descriptionName: post["description"] ?? "", typePet: post["typePet"] ?? "", oldPet: post["oldPet"] ?? "", lostAdress: post["lostAdress"] ?? "", curentDate: post["curentDate"] ?? ""))
                }
                completion(resultMass)
            }
        }
    }
    
    func saveImage(_ storage: [Data],_ userID: String,  completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("postImages").child(userID)        
        if  storage.count > 0 {
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
    }
    
    func save(posts: [AdvertProtocol], id: String,  stroage: [Data]) {
        let ref = Database.database().reference().child("posts")
        var list = String()
        ref.getData { (err, snap) in
            guard err == nil else {
                return
            }
            self.saveImage(stroage, "\(id)") { data in
                DispatchQueue.global().async {
                    list += "\(data) "
                    DispatchQueue.main.async {
                        ref.child("\(id)").setValue(["postName": posts.first?.postName, "description": posts.first?.descriptionName, "typePet": posts.first?.typePet, "oldPet": posts.first?.oldPet, "lostAdress": posts.first?.lostAdress, "curentDate": posts.first?.curentDate, "breed": posts.first?.breed, "typePost": posts.first?.typePost, "listLinks": list, "phoneNumber": posts.first?.phoneNumber, "postID": "\(id)", "countComments": posts.first?.countComments])
                    }
                }
            }
        }
    }
    
}
