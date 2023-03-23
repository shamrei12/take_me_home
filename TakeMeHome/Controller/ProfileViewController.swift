//
//  ProfileViewController.swift
//  FindMyPets
//
//  Created by Алексей Шамрей on 27.12.22.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak private var bulletinTupped: UIBarButtonItem!
    private var choiceButton: Bool = false
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    private var fbManager: FirebaseData!
    private var listIdPost = [String]()
    private var posts = [[AdvertProtocol]]()
    private var fbData: FirebaseData?
    
    @IBOutlet weak var tableview: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbManager = FirebaseData()
        getPosts()
        fbData = FirebaseData()
        
        tableview.register(UINib(nibName: "UserPostTableViewCell", bundle: nil), forCellReuseIdentifier: "UserPostTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        imageProfile.image = UIImage(named: "appLogo")
    }
    
    func updateUI() {
        fbData?.getUserName { name in
            self.userName.text = name
        }
        
    }
    
    @IBAction func iditProfileTapped(_ sender: UIButton) {
        //        let iditProfile = EditProfileViewController.instantiate()
        //        iditProfile.modalPresentationStyle = .formSheet
        //        present(iditProfile, animated: true)
        
    }
    
    
    @IBAction func backtapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    
    @IBAction func addPhoto(_ sender: UIButton) {
        //        imagePicker.sourceType = .photoLibrary
        //        imagePicker.allowsEditing = true
        //        present(imagePicker, animated: true)
    }
    
    func getPosts() {
        posts.removeAll()
        fbManager.loadUserPostsLinks { [self] idPosts in
            for id in idPosts {
                fbManager.loadSinglePost(id: id) { data in
                    self.posts.append(data)
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                }
            }
            
        }
    }
    
    
}

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    //    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //        let image = (
    //            info[UIImagePickerController.InfoKey.editedImage] as? UIImage ??
    //                       info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    //        )
    //        imageProfile.image = image
    //        dismiss(animated: true)
    //    }
    //
}

extension ProfileViewController: UITableViewDataSource {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UserPostTableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "UserPostTableViewCell") as? UserPostTableViewCell {
            cell = reuseCell
        } else {
            cell = UserPostTableViewCell()
        }
        
        return configure(cell: cell, for: indexPath)
    }
    
    private func configure(cell: UserPostTableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        DispatchQueue.global().async { [self] in
            let resurse = ImageResource(downloadURL: URL(string: ConverterLinks.shared.getFirstLinks(posts[indexPath.row].first!.linkImage ))!)
            let processor = DownsamplingImageProcessor(size: CGSize(width: 50, height: 50))
            DispatchQueue.main.async {
                cell.imageView!.kf.setImage(with: resurse, options: [.processor(processor)])
                cell.postName.text = posts[indexPath.row].first?.postName
                cell.countComments.text = posts[indexPath.row].first?.countComments
            }
        }
        return cell
    }
}


extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let adverpage = AdvertPageViewController.instantiate()
        adverpage.modalPresentationStyle = .fullScreen
        adverpage.updateUIElements(posts[indexPath.row].first!.postId)
        present(adverpage, animated: true)
    }
}
