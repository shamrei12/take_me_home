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
    @IBOutlet private weak var checkList: UIButton!
    private var sideMenuShadowView: UIView!
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    private var revealSideMenuOnTop: Bool = true
    private var fbManager: FirebaseData!
    private var coreData: CoreDataClass!
    private var filterMass:  [AdvertProtocol] = []
    private var advertMass: [AdvertProtocol] = []
    private var reloadTableView: Bool = true
    private var searching = false
    private var storage = UserDefaults.standard
    private var storageKey = "login"
    
    private var countDog = 0
    private var countCat = 0
    private var countOther = 0
    
    @IBOutlet weak var createAdvertButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak private var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbManager = FirebaseData()
        coreData = CoreDataClass()
        firstStart()
        createAdvertButton.layer.cornerRadius = 10
        tableView.register(UINib(nibName: "AdvertTableViewCell", bundle: nil), forCellReuseIdentifier: "AdvertTableViewCell")
        tableView.register(UINib(nibName: "NoPostTableViewCell", bundle: nil), forCellReuseIdentifier: "NoPostTableViewCell")
        collectionView.register(UINib(nibName: "AdvertCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AdvertCollectionViewCell")
        self.hideKeyboardWhenTappedAround()
        navigationItem.title = "Объявления"


    }
    
    
    @objc func buttonTapped() {
        tableView.reloadData()
    }
    
    func firstStart() {
        if storage.object(forKey: storageKey) == nil {
            storage.set("\(coreData.getUUID())", forKey: storageKey)
            fbManager.registrUser(login: storage.object(forKey: storageKey) as! String, name: "Пользователь")
        }
    }
    
    
    @IBAction func showCreateAdvert(_ sender: UIButton) {
        let createVC = CreateAdvertViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: createVC)
        createVC.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        reloadTableView = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func getData() {
        fbManager.load() { [self] data in
            if data.count > advertMass.count {
                if reloadTableView {
                    reloadTableView = false
                    DispatchQueue.main.async {
                        self.advertMass.removeAll()
                        self.countDog = 0
                        self.countCat = 0
                        self.countOther = 0
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
            let navigationController = UINavigationController(rootViewController: adverpage)
            navigationController.modalPresentationStyle = .fullScreen
            adverpage.updateUIElements(filterMass[indexPath.row].postId)
            present(navigationController, animated: true)
        } else {
            let adverpage = AdvertPageViewController.instantiate()
            let navigationController = UINavigationController(rootViewController: adverpage)
            navigationController.modalPresentationStyle = .fullScreen
            adverpage.updateUIElements(advertMass[indexPath.row].postId)
            present(navigationController, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension AdvertViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            if filterMass.count == 0 {
                return 1
            } else {
                return filterMass.count
            }
        } else {
            if advertMass.count == 0 {
                return 1
            } else {
                return advertMass.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if advertMass.count == 0 && filterMass.count == 0 {
            var cell: NoPostTableViewCell
            if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "NoPostTableViewCell") as? NoPostTableViewCell {
                cell = reuseCell
            } else {
                cell = NoPostTableViewCell()
            }
            return configure(cell: cell, for: indexPath)
        } else if filterMass.count == 0 && searching {
            var cell: NoPostTableViewCell
            if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "NoPostTableViewCell") as? NoPostTableViewCell {
                cell = reuseCell
            } else {
                cell = NoPostTableViewCell()
            }
            return configure(cell: cell, for: indexPath)
        }else {
            var cell: AdvertTableViewCell
            if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "AdvertTableViewCell") as? AdvertTableViewCell {
                cell = reuseCell
            } else {
                cell = AdvertTableViewCell()
            }
            
            return configure(cell: cell, for: indexPath)
        }
    }
    
    private func configure(cell: NoPostTableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        return cell
    }
    
    private func configure(cell: AdvertTableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        if searching {
                DispatchQueue.global().async { [self] in
                    let resurse = ImageResource(downloadURL: URL(string: filterMass[indexPath.row].linkImage)!, cacheKey: filterMass[indexPath.row].linkImage)
                    DispatchQueue.main.async { [self] in
                        cell.postImageView.kf.setImage(with: resurse)
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
                DispatchQueue.main.async { [self] in
                    cell.postImageView.kf.setImage(with: resurse)
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


