//
//  AdvertPageViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 18.02.23.
//

import UIKit
import Kingfisher

class AdvertPageViewController: UIViewController {
    
    
    @IBOutlet weak var postID: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var postName: UILabel!
    @IBOutlet weak var oldPet: UILabel!
    @IBOutlet weak var descriptionPost: UILabel!
    @IBOutlet weak var breedPet: UILabel!
    @IBOutlet weak var lostAdress: UILabel!
    @IBOutlet weak var numberPhone: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendMessage: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollViewImage: UIScrollView!
    private var moveTextField = true
    

    @IBOutlet weak var collectionView: UICollectionView!
    private var listResourse = [ImageResource]()
    private var commentsPost = [Comments]()
    
    @IBOutlet weak var bottonScrollviewConstraint: NSLayoutConstraint!
    
    private var fbManager: FirebaseData!
    private var stringPostID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        pageControl.hidesForSinglePage = true
        fbManager = FirebaseData()
        collectionView.register(UINib(nibName: "ImagePostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImagePostCollectionViewCell")
        tableview.register(UINib(nibName: "CommentsPostTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentsPostTableViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
//        updateFrame()
        

    }
//
    @objc func keyboardWillShow(notification: NSNotification) {
        if moveTextField {
            moveTextField = false
            if messageField.isEditing {
                guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
                let keyboardHeight = keyboardSize.height
                let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0)
                let bottomConstant: CGFloat = 20
                bottonScrollviewConstraint.constant -= keyboardHeight / 2.1
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //        if self.view.frame.origin.y != 0 {
        //            self.view.frame.origin.y = 0
        //        }
        moveTextField = true
        bottonScrollviewConstraint.constant = 0
        
    }
    
    
    
//    func updateFrame() {
//        self.scrollView.contentSize = CGSize(width: self.contentView.frame.width, height: self.contentView.frame.height)
//
//        self.contentView.translatesAutoresizingMaskIntoConstraints = false
//        self.contentView.clipsToBounds = true
//    }
    
    @IBAction func callTapped(_ sender: UIButton) {
    
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendMessageTapped(_ sender: UIButton) {
        if messageField.text?.count != 0 {
            fbManager.getUserName(completion: { [self] user in
                fbManager.SaveComment(id: stringPostID , key: user, value: messageField.text ?? "")
                DispatchQueue.main.async {
                    self.messageField.text = ""
                }
            })
            }
    }
    
    func updateUIElements(_ id: String) {
        var list = [String]()
        
        fbManager.loadComments(id: id) { dataComments in
            DispatchQueue.main.async {
                self.commentsPost.removeAll()
                self.commentsPost = dataComments
                self.tableview.reloadData()
            }
            
            
        }
        fbManager.loadSinglePost(id: id) { data in
            DispatchQueue.global().async { [self] in
                list = ConverterLinks.shared.getListLinks(data.first?.linkImage ?? "")
                for i in list {
                    self.listResourse.append(ImageResource(downloadURL: URL(string: i)!))
                    }
               
                }
                
//                let resurse = ImageResource(downloadURL: URL(string: data.first?.linkImage ?? "")!)
                DispatchQueue.main.async { [self] in
                    
                    collectionView.reloadData()
                    pageControl.numberOfPages = listResourse.count
//                    self.pageControll.numberOfPages = list.count
    //                self.advertImage.kf.setImage(with: resurse)
                    self.postID.text = data.first?.typePost
                    self.date.text = data.first?.curentDate
                    self.postName.text = data.first?.postName
                    self.descriptionPost.text = data.first?.descriptionName
                    self.oldPet.text = "Возраст: \(data.first?.oldPet ?? "")"
                    self.breedPet.text = "Порода: \(data.first?.breed ?? "")"
                    self.lostAdress.text = "Адрес: \(data.first?.lostAdress ?? "")"
                    self.numberPhone.text = data.first?.phoneNumber
                    stringPostID = data.first?.postId ?? ""
                }
            }
        }
}

//extension AdvertPageViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let page = scrollViewImage.contentOffset.x/scrollViewImage.frame.width
//        pageControll.currentPage = Int(page)
//    }
//
//}

extension AdvertPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listResourse.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: ImagePostCollectionViewCell
        if let reuseCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePostCollectionViewCell", for: indexPath) as? ImagePostCollectionViewCell {
            cell = reuseCell
        } else {
            cell = ImagePostCollectionViewCell()
        }
        return configure(cell: cell, for: indexPath)
    }
    
    private func configure(cell: ImagePostCollectionViewCell, for indexPath: IndexPath) -> UICollectionViewCell {

        cell.imagePost.kf.setImage(with: listResourse[indexPath.row])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.section
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
    }
    
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
         var scrollPos = scrollView.contentOffset.x / view.frame.width
         scrollPos.round()
         pageControl.currentPage = Int(scrollPos)
    }
}

extension AdvertPageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        commentsPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CommentsPostTableViewCell
          if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "CommentsPostTableViewCell") as? CommentsPostTableViewCell {
              cell = reuseCell
          } else {
              cell = CommentsPostTableViewCell()
          }
          
          return configure(cell: cell, for: indexPath)
    }
    
    func configure(cell: CommentsPostTableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        cell.nameUser.text = commentsPost[indexPath.row].name
        cell.textComment.text = commentsPost[indexPath.row].comment
        return cell
    }
}
