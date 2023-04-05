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

class AdvertViewController: UIViewController, AlertDelegate {
    
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
    private var coreData: CoreDataClass!
    private var filterMass:  [AdvertProtocol] = []
    private var advertMass: [AdvertProtocol] = []
    private var reloadTableView: Bool = true
    private var alertView: AlertInDevelop!
    private var searching = false
    
    private var countDog = 0
    private var countCat = 0
    private var countOther = 0
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak private var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuButton.layer.cornerRadius = 5
        mapButton.layer.cornerRadius = 5
        tableView.register(UINib(nibName: "AdvertTableViewCell", bundle: nil), forCellReuseIdentifier: "AdvertTableViewCell")
        collectionView.register(UINib(nibName: "AdvertCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AdvertCollectionViewCell")
        fbManager = FirebaseData()
        coreData = CoreDataClass()
        self.hideKeyboardWhenTappedAround()
    }


    override func viewWillAppear(_ animated: Bool) {
        getData()
        reloadTableView = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureMenuViewController()
        showBulletinViewController(shouldMove: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sideMenuViewController.view.isHidden = true
    }

    
    @IBAction func showMap(_ sender: UIButton) {
        alertView = AlertInDevelop.loadFromNib()
        alertView.delegate = self
        UIApplication.shared.keyWindow?.addSubview(alertView)
        alertView.center = CGPoint(x: mainView.frame.size.width  / 2,
                                   y: mainView.frame.size.height / 2)
    }
    
    func cancelScene() {
        alertView.removeFromSuperview()
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
        sideMenuViewController.view.isHidden = false
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
                self.sideMenuViewController.viewWillDisappear(true)
            })
        }
    }
    
    func getData() {
        fbManager.load() { [self] data in
            if data.count > advertMass.count {
                if reloadTableView {
                    reloadTableView = false
                    DispatchQueue.main.async {
                        advertMass.removeAll()
                        countDog = 0
                        countCat = 0
                        countOther = 0
                        for i in 0...data.count - 1 {
                            self.advertMass.append(AdvertPost(countComments: data[i].countComments, postId: data[i].postId, phoneNumber: data[i].phoneNumber, linkImage:  ConverterLinks.shared.getFirstLinks(data[i].linkImage), typePost: data[i].typePost, breed: data[i].breed, postName: data[i].postName, descriptionName: data[i].descriptionName, typePet: data[i].typePet, oldPet: data[i].oldPet, lostAdress: data[i].lostAdress, curentDate: data[i].curentDate))
                            self.countingType(data[i].typePet)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func countingType(_ type: String) {
        if type == "Собака" {
            countDog += 1
        } else if type == "Кошка" {
            countCat += 1
        } else if type == "Другое" {
            countOther += 1
        }
        collectionView.reloadData()
    }
    
    @IBAction func swipeLeftTapped(_ sender: UISwipeGestureRecognizer) {
        configureMenuViewController()
        showBulletinViewController(shouldMove: false)
    }
}

extension AdvertViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterMass.removeAll()
        guard !searchText.isEmpty else {
            searching = false
            tableView.reloadData()
            return
        }
        let text = searchText.lowercased()
        filterMass = advertMass.filter { $0.postName.lowercased().contains(text) }
        searching = true
        tableView.reloadData()
    }
}

extension AdvertViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching {
            let adverpage = AdvertPageViewController.instantiate()
            adverpage.modalPresentationStyle = .fullScreen
            adverpage.updateUIElements(filterMass[indexPath.row].postId)
            present(adverpage, animated: true)
        } else {
            let adverpage = AdvertPageViewController.instantiate()
            adverpage.modalPresentationStyle = .fullScreen
            adverpage.updateUIElements(advertMass[indexPath.row].postId)
            present(adverpage, animated: true)
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension AdvertViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filterMass.count
        } else {
            return advertMass.count
        }
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
        if searching {
            DispatchQueue.global().async { [self] in
                let resurse = ImageResource(downloadURL: URL(string: filterMass[indexPath.row].linkImage)!, cacheKey: filterMass[indexPath.row].linkImage)
                let processor = DownsamplingImageProcessor(size: CGSize(width: 128, height: 128))
                DispatchQueue.main.async { [self] in
                    cell.imageView!.kf.setImage(with: resurse, options: [.processor(processor)])
                    cell.postName.text = filterMass[indexPath.row].postName
                    cell.oldPet.text = "Возраст: \(filterMass[indexPath.row].oldPet)"
                    cell.breed.text = "Порода: \(filterMass[indexPath.row].breed)"
                    cell.lostAdress.text = filterMass[indexPath.row].lostAdress
                }
            }
            return cell
        } else {
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
}

extension AdvertViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
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
        
        if indexPath.row == 0 {
            cell.categoryImage.image = UIImage(named: "dog")
            cell.categoryLabel.text = "Собаки: \(countDog)"
        } else if indexPath.row == 1 {
            cell.categoryImage.image = UIImage(named: "cat")
            cell.categoryLabel.text = "Кошки: \(countCat)"
        } else {
            cell.categoryImage.image = UIImage(named: "owl")
            cell.categoryLabel.text = "Прочее: \(countOther)"
        }
        return cell
    }
    
}


