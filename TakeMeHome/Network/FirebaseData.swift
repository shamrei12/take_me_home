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
        let ref = Database.database().reference().child("posts")
        ref.observe(.value) { snap in
            var resultMass: [AdvertProtocol] = []
            guard let snapshots = snap.children.allObjects as? [DataSnapshot] else {
                return
            }
            for snap in snapshots {
                guard let post = snap.value as? [String: Any] else {
                    continue
                }
                let author = post["author"] as? String ?? ""
                let countComments = post["countComments"] as? String ?? ""
                let postId = post["postID"] as? String ?? ""
                let phoneNumber = post["phoneNumber"] as? String ?? ""
                let linkImage = post["listLinks"] as? [String] ?? [""]
                let typePost = post["typePost"] as? String ?? ""
                let breed = post["breed"] as? String ?? ""
                let postName = post["postName"] as? String ?? ""
                let descriptionName = post["description"] as? String ?? ""
                let typePet = post["typePet"] as? String ?? ""
                let oldPet = post["oldPet"] as? String ?? ""
                let lostAdress = post["lostAdress"] as? String ?? ""
                let curentDate = post["curentDate"] as? String ?? ""
                let advertPost = AdvertPost(author: author, countComments: countComments, postId: postId, phoneNumber: phoneNumber, linkImage: linkImage, typePost: typePost, breed: breed, postName: postName, descriptionName: descriptionName, typePet: typePet, oldPet: oldPet, lostAdress: lostAdress, curentDate: curentDate)
                resultMass.append(advertPost)
            }
            completion(resultMass)
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
    
    func loadSinglePost(id: String, completion: @escaping ([AdvertProtocol]) -> Void) {
        let ref = Database.database().reference().child("posts").child(id)
        ref.observeSingleEvent(of: .value) { snap in
            var resultMass: [AdvertProtocol] = []
            if let post = snap.value as? [String: Any] {
                let author = post["author"] as? String ?? ""
                let countComments = post["countComments"] as? String ?? ""
                let postId = post["postID"] as? String ?? ""
                let phoneNumber = post["phoneNumber"] as? String ?? ""
                let linkImage = post["listLinks"] as? [String] ?? [""]
                let typePost = post["typePost"] as? String ?? ""
                let breed = post["breed"] as? String ?? ""
                let postName = post["postName"] as? String ?? ""
                let descriptionName = post["description"] as? String ?? ""
                let typePet = post["typePet"] as? String ?? ""
                let oldPet = post["oldPet"] as? String ?? ""
                let lostAdress = post["lostAdress"] as? String ?? ""
                let curentDate = post["curentDate"] as? String ?? ""
                let advertPost = AdvertPost(author: author, countComments: countComments, postId: postId, phoneNumber: phoneNumber, linkImage: linkImage, typePost: typePost, breed: breed, postName: postName, descriptionName: descriptionName, typePet: typePet, oldPet: oldPet, lostAdress: lostAdress, curentDate: curentDate)
                resultMass.append(advertPost)
            }
            completion(resultMass)
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
            if let complains = snapshot.value as? [String]  {
                completion(complains)
            } else {
                completion([])
            }
        }
    }
    
    func save(posts: [AdvertProtocol], id: String, storage: [Data], completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference().child("posts")
        var list: [String] = []
        ref.observeSingleEvent(of: .value) { snap in
            for child in snap.children {
                if let childSnapshot = child as? DataSnapshot,
                   let post = childSnapshot.value as? [String: Any],
                   let postId = post["postID"] as? String,
                   postId == id {
                    completion(false)
                    return
                }
            }
            self.saveImage(storage, id) { urls in
                list = [urls]
                let post = ["postName": posts.first?.postName,
                            "description": posts.first?.descriptionName,
                            "typePet": posts.first?.typePet,
                            "oldPet": posts.first?.oldPet,
                            "lostAdress": posts.first?.lostAdress,
                            "curentDate": posts.first?.curentDate,
                            "breed": posts.first?.breed,
                            "typePost": posts.first?.typePost,
                            "listLinks": list,
                            "phoneNumber": posts.first?.phoneNumber,
                            "postID": id,
                            "countComments": posts.first?.countComments] as [String: Any]
                ref.child(id).setValue(post) { error, _ in
                    if error != nil {
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }

    
}
