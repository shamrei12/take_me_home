//
//  AdvertPageViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 18.02.23.
//

import UIKit
import Kingfisher

class AdvertPageViewController: UIViewController, UIAlertViewDelegate, AlertDelegate, UITextFieldDelegate {
    
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
    
    private var moveTextField = true
    private var idPost = ""
    @IBOutlet weak var collectionView: UICollectionView!
    private var listResourse = [ImageResource]()
    private var commentsPost = [Comments]()
    private var fbManager: FirebaseData!
    private var stringPostID: String = ""
    private var adresForMap: String = ""
    private var alertView: AlertInDevelop!
    
    @IBOutlet weak var mainView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        pageControl.hidesForSinglePage = true
        messageField.delegate = self
        fbManager = FirebaseData()
        collectionView.register(UINib(nibName: "ImagePostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImagePostCollectionViewCell")
        tableview.register(UINib(nibName: "CommentsPostTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentsPostTableViewCell")

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            var contentInsets = scrollView.contentInset
        contentInsets.bottom = -(textField.frame.maxY - scrollView.frame.height + 10) / 2
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            scrollView.setContentOffset(CGPoint(x: 0, y: -contentInsets.bottom), animated: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        var contentInsets = scrollView.contentInset
        contentInsets.bottom = 0
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        moveTextField = true
        scrollView.scrollToDown()
        
    }
    
    @IBAction func callTapped(_ sender: UIButton) {
        
    }
    
    func loadComments() {
        fbManager.loadComments(id: stringPostID) { comments in
            self.commentsPost = comments
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    @IBAction func openMap(_ sender: UIBarButtonItem) {
        //        let mapPage = MapPositionViewController.instantiate()
        //        mapPage.modalPresentationStyle = .pageSheet
        //        mapPage.updateMap(adress: adresForMap)
        //        present(mapPage, animated: true)
        //        showAlert(self.view)
        alertView = AlertInDevelop.loadFromNib()
        alertView.delegate = self
        UIApplication.shared.keyWindow?.addSubview(alertView)
        alertView.center = CGPoint(x: mainView.frame.size.width  / 2,
                                   y: mainView.frame.size.height / 2)
    }
    
    func cancelScene() {

        alertView.removeFromSuperview()

    }
    
    func scrollDown() {
        let numberOfROws = self.tableview.numberOfRows(inSection: 0)
        let indexPath = IndexPath(row: numberOfROws, section: 0)
        self.tableview.insertRows(at: [indexPath], with: .automatic)
        self.tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func updateComments(comment: Comments) {
        DispatchQueue.main.async {
            self.commentsPost.append(comment)
            self.scrollDown()
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendMessageTapped(_ sender: UIButton) {
        if let message = messageField.text, !message.isEmpty {
            fbManager.getUserName(completion: { [self] user in
                let comment = UserComments(name: user, comment: message)
                fbManager.SaveComment(id: stringPostID , key: user, value: message)
                DispatchQueue.main.async {
                    self.messageField.text = ""
                    self.updateComments(comment: comment)
                }
            })
        }
    }
    
    func updateUIElements(_ id: String) {
        var list = [String]()
        idPost = id
        fbManager.loadSinglePost(id: id) { data in
            DispatchQueue.global().async { [self] in
                list = ConverterLinks.shared.getListLinks(data.first?.linkImage ?? "")
                for i in list {
                    self.listResourse.append(ImageResource(downloadURL: URL(string: i)!))
                }
            }
            
            DispatchQueue.main.async { [self] in
                collectionView.reloadData()
                pageControl.numberOfPages = listResourse.count
                self.postID.text = data.first?.typePost
                self.date.text = data.first?.curentDate
                self.postName.text = data.first?.postName
                self.descriptionPost.text = data.first?.descriptionName
                self.oldPet.text = "Возраст: \(data.first?.oldPet ?? "")"
                self.breedPet.text = "Порода: \(data.first?.breed ?? "")"
                self.lostAdress.text = "Адрес: \(data.first?.lostAdress ?? "")"
                self.numberPhone.text = data.first?.phoneNumber
                stringPostID = data.first?.postId ?? ""
                loadComments()
                adresForMap = data.first?.lostAdress ?? ""
            }
        }
    }
}

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
        var scrollPos = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(scrollPos)
        let contentOffset = CGPoint(x: scrollView.frame.width * CGFloat(pageControl.currentPage) - 20, y: 0)
        scrollView.setContentOffset(contentOffset, animated: false)
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


