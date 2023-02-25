//
//  AdvertViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 4.02.23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import Kingfisher

class AdvertViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var menuButton: UIButton!
    @IBOutlet private weak var mapButton: UIButton!
    @IBOutlet private weak var checkList: UIButton!
    private var sideMenuShadowView: UIView!
    private var sideMenuViewController: SideMenuViewController!
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    private var revealSideMenuOnTop: Bool = true
    private var fbManager: FirebaseData!
    var advertMass: [AdvertProtocol] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sideMenuShadowView = UIView(frame: self.view.bounds)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0
        menuButton.layer.cornerRadius = 5
        mapButton.layer.cornerRadius = 5
        checkList.layer.cornerRadius = 5
        tableView.register(UINib(nibName: "AdvertTableViewCell", bundle: nil), forCellReuseIdentifier: "AdvertTableViewCell")
        collectionView.register(UINib(nibName: "AdvertCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AdvertCollectionViewCell")
        fbManager = FirebaseData()
    }
    
        @IBAction func signOut(_ sender: UIButton) {
        }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }

    func configureMenuViewController() {
        if sideMenuViewController == nil {
            sideMenuViewController = SideMenuViewController.instantiate()
            view.insertSubview(sideMenuViewController.view, at: 5)
            addChild(sideMenuViewController)
            sideMenuViewController.view.frame.size.width = 0
        }
    }
    
    @IBAction func menuTapped(_ sender: UIButton) {
        configureMenuViewController()
        showBulletinViewController(shouldMove: true)
    }
    
    func showBulletinViewController(shouldMove: Bool ) {
         if shouldMove {
             // show
             UIView.animate(withDuration: 0.5,
                            delay: 0,
                            usingSpringWithDamping: 0.8,
                            initialSpringVelocity: 0,
                            options: .curveEaseInOut,
                            animations: {
                 self.sideMenuViewController.view.frame.size.width = 300
                 self.sideMenuViewController.viewWillAppear(true)


             })
         } else {
             UIView.animate(withDuration: 0.5,
                            delay: 0,
                            usingSpringWithDamping: 0.8,
                            initialSpringVelocity: 0,
                            options: .curveEaseInOut,
                            animations: {
                 self.sideMenuViewController.view.frame.size.width = 0
                 self.sideMenuViewController.viewDidDisappear(true)

             })
         }
     }
    
    @IBAction func mapTapped(_ sender: UIButton) {

    }
    
    func getData() {
        advertMass.removeAll()
        fbManager.load() { data in
            if data.count > 0 {
                for i in 0...data.count - 1 {
                    self.advertMass.append(AdvertPost(postId: data[i].postId, phoneNumber: data[i].phoneNumber, linkImage:  ConverterLinks.shared.getFirstLinks(data[i].linkImage), typePost: data[i].typePost, breed: data[i].breed, postName: data[i].postName, descriptionName: data[i].descriptionName, typePet: data[i].typePet, oldPet: data[i].oldPet, lostAdress: data[i].lostAdress, curentDate: data[i].curentDate))
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func swipeLeftTapped(_ sender: UISwipeGestureRecognizer) {
        configureMenuViewController()
        showBulletinViewController(shouldMove: false)
    }
    
}

extension AdvertViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let adverpage = AdvertPageViewController.instantiate()
        adverpage.modalPresentationStyle = .fullScreen
        adverpage.updateUIElements(advertMass[indexPath.row].postId)
        present(adverpage, animated: true)
    }
}

extension AdvertViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        advertMass.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: AdvertTableViewCell
          if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "AdvertTableViewCell") as? AdvertTableViewCell {
              cell = reuseCell
          } else {
              cell = AdvertTableViewCell()
          }
          
          return configure(cell: cell, for: indexPath)
    }
    
    private func configure(cell: AdvertTableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        
        DispatchQueue.global().async { [self] in
            let resurse = ImageResource(downloadURL: URL(string: advertMass[indexPath.row].linkImage)!, cacheKey: advertMass[indexPath.row].linkImage)
            let processor = DownsamplingImageProcessor(size: CGSize(width: 128, height: 128))
                DispatchQueue.main.async { [self] in
                    cell.imageView!.kf.setImage(with: resurse, options: [.processor(processor)])
                    cell.postName.text = advertMass[indexPath.row].postName
                    cell.oldPet.text = "Возраст: \(advertMass[indexPath.row].oldPet)"
                    cell.breed.text = "Порода: \(advertMass[indexPath.row].breed)"
                    cell.lostAdress.text = advertMass[indexPath.row].lostAdress
                }
            }
        
        return cell
    }
}


extension AdvertViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         var cell: AdvertCollectionViewCell
         if let reuseCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdvertCollectionViewCell", for: indexPath) as? AdvertCollectionViewCell {
             cell = reuseCell
         } else {
             cell = AdvertCollectionViewCell()
         }
         return configure(cell: cell, for: indexPath)
     }
     
     private func configure(cell: AdvertCollectionViewCell, for indexPath: IndexPath) -> UICollectionViewCell {
         return cell
 }
    
}


