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
    private var storage = UserDefaults.standard
    private var storageKey = "login"
    
    func load(completion: @escaping ([AdvertProtocol]) -> Void) {
        var resultMass: [AdvertProtocol] = []
        let ref = Database.database().reference().child("posts")
        ref.observe(.value) { snap in
            resultMass.removeAll()
            if let snapshots = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    if let post = snap.value as? Dictionary<String, AnyObject> {
                        resultMass.append(AdvertPost(countComments: post["countComments"] as? String ?? "", postId: post["postID"] as? String ?? "", phoneNumber: post["phoneNumber"] as? String ?? "", linkImage: post["listLinks"] as? String ?? "", typePost: post["typePost"] as? String ?? "", breed: post["breed"] as? String ?? "", postName: post["postName"] as? String ?? "", descriptionName: post["description"] as? String ?? "", typePet: post["typePet"] as? String ?? "", oldPet: post["oldPet"] as? String ?? "", lostAdress: post["lostAdress"] as? String ?? "", curentDate: post["curentDate"] as? String ?? ""))
                    }
                }
                completion(resultMass)
            }
        }
    }
    
    func registrUser(login: String, name: String) {
        let ref = Database.database().reference().child("users")
        ref.child(login).getData { (err, snap) in
            ref.child(login).setValue(["name": name])
        }
        ref.child(login)
    }
    
    func saveIDPostUser(id: String, login: String) {
        let ref = Database.database().reference().child("users").child(login)
        
        ref.child("idPosts").getData { (err, snap) in
            ref.child("idPosts").child("\(snap!.childrenCount + 1)").setValue("\(id)")
        }
    }
    
    //    func loadUserPostsLinks(completion: @escaping (([String]) -> Void)) {
    //        var list = [String]()
    //        let login = storage.object(forKey: storageKey) as? String ?? ""
    //        let userID = Auth.auth().currentUser?.uid
    //        let ref = Database.database().reference().child("users").child(login).child("idPosts")
    //
    //        ref.observe(.value) { snap in
    //            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
    //                for idPost in snapshot {
    //                    if idPost.value is String {
    //                        list.append(idPost.value as! String)
    //                    }
    //                }
    //                completion(list)
    //            }
    //        }
    //    }
    
    func getUserName(completion: @escaping (String) -> Void) {
        let ref = Database.database().reference().child("users").child(storage.object(forKey: storageKey) as! String)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String: Any], let name = value["name"] as? String {
                completion(name)
            } else {
                completion("Пользователь")
            }
        } withCancel: { (error) in
            print("Error getting user name: \(error.localizedDescription)")
            completion("Пользователь")
        }
    }
    
    //MARK: Comments
    func SaveComment(id: String, key: String, value: String, count: Int) {
        let ref = Database.database().reference().child("posts").child(id)
        
        ref.getData { (err, snap) in
            ref.child("comments").child("\(count)").setValue([key:value])
            ref.child("countComments").setValue("\(count)")
            
        }
    }
    
    func loadComments(id: String, completion: @escaping ([Comments]) -> Void) {
        let ref = Database.database().reference().child("posts").child("\(id)").child("comments")
        var commentsUser = [Comments]()
        ref.observeSingleEvent(of: .value) { snap in
            if let snapshots = snap.children.allObjects as? [DataSnapshot] {
                for comments in snapshots {
                    if let comment = comments.value as? Dictionary<String, String> {
                        commentsUser.append(UserComments(name: comment.first?.key ?? "", comment: comment.first?.value ?? ""))
                    }
                }
                completion(commentsUser)
            }
        }
    }
    
    func loadSinglePost (id: String ,completion: @escaping ([AdvertProtocol]) -> Void) {
        var resultMass: [AdvertProtocol] = []
        let ref = Database.database().reference().child("posts").child(id)
        ref.observe(.value) { snap in
            if let snapshots = snap.children.allObjects as? [DataSnapshot] {
                if let post = snap.value as? Dictionary<String, AnyObject>  {
                    resultMass.append(AdvertPost(countComments: post["countComments"] as? String ?? "", postId: post["postID"] as? String ?? "", phoneNumber: post["phoneNumber"] as? String ?? "", linkImage: post["listLinks"] as? String ?? "", typePost: post["typePost"] as? String ?? "", breed: post["breed"] as? String ?? "", postName: post["postName"] as? String ?? "", descriptionName: post["description"] as? String ?? "", typePet: post["typePet"] as? String ?? "", oldPet: post["oldPet"] as? String ?? "", lostAdress: post["lostAdress"] as? String ?? "", curentDate: post["curentDate"] as? String ?? ""))
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
    
    func saveComplainUser(postID: String, UserID: String) {
        let ref = Database.database().reference().child("posts").child(postID).child("Complains")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if var complains = snapshot.value as? [String]  {
                if !complains.contains(UserID) {
                    complains.append(UserID)
                    ref.setValue(complains)
                }
            } else {
                ref.setValue([UserID])
            }
        }
    }
    
    func loadComplainUser(postID: String, completion: @escaping ([String]) -> Void) {
        let ref = Database.database().reference().child("posts").child(postID).child("Complains")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if var complains = snapshot.value as? [String]  {
                completion(complains)
            } else {
                completion([])
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
