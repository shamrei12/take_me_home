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

class AdvertViewController: UIViewController, FirstStartDelegate, Complain {
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var catButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var dogButton: UIButton!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak  var mainView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var countAllLabel: UILabel!
    @IBOutlet weak var countDogLabel: UILabel!
    @IBOutlet weak var countCatLabel: UILabel!
    @IBOutlet weak var countOtherLabel: UILabel!
    private var userDefaults: UserDefaultsModel!
    private var fbManager: FirebaseData!
    private var coreData: CoreDataClass!
    private var filterMass:  [AdvertProtocol] = []
    private var advertMass: [AdvertProtocol] = []
    private var samplingMass: [AdvertProtocol] = []
    private var searching = false
    private var alertView: EULAViewController!
    private var advertTableVC: AdvertTableViewCell!
    private var complainVC: CimplainView!
    private var idPost = String()
    private var countDog = 0
    private var countCat = 0
    private var countOther = 0
    private let createButton = UIButton(type: .system)
    private var checkCtriteria: Bool = false
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbManager = FirebaseData()
        coreData = CoreDataClass()
        firstStart()
        tableView.register(UINib(nibName: "AdvertTableViewCell", bundle: nil), forCellReuseIdentifier: "AdvertTableViewCell")
        tableView.register(UINib(nibName: "NoPostTableViewCell", bundle: nil), forCellReuseIdentifier: "NoPostTableViewCell")
        self.hideKeyboardWhenTappedAround()
        navigationItem.title = "Объявления"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func showCreateAdvert(_ sender: UIButton) {
        let createVC = CreateAdvertViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: createVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    func showAlert() {
        alertView = EULAViewController.instantiate()
        alertView.delegate = self
        view.addSubview(alertView!.view)
        addChild(alertView!)
        alertView.didMove(toParent: self)
    }
    
    func cancelScene() {
        if alertView != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.alertView!.view.alpha = 0
            }) { (finished) in
                self.alertView!.view.removeFromSuperview()
                self.alertView!.removeFromParent()
                self.alertView = nil
            }
//            storage.set("\(coreData.getUUID())", forKey: storageKey)
            fbManager.registrUser(login: "\(coreData.getUUID())", name: "Пользователь")
            getData()
        }
    }
    
    func firstStart() {
        if UserDefaultsModel.shared.checkUserLoggin() {
            showAlert()
        } else {
            getData()
        }
    }
    
    func complain(_ index: Int) {
        if searching {
            idPost = filterMass[index].postId
        } else {
            idPost = advertMass[index].postId
        }
        complainViewShow()
    }
    
    func complainViewShow() {
        UIView.animate(withDuration: 0.4) {
            self.view.alpha = 0.6
            self.view.isUserInteractionEnabled = false
        }
        complainVC = CimplainView.loadFromNib()
        complainVC.delegate = self
        UIApplication.shared.keyWindow?.addSubview(complainVC)
        complainVC.center = CGPoint(x: mainView.frame.size.width  / 2,
                                    y: mainView.frame.size.height / 2)
    }
    
    func cancel() {
        UIView.animate(withDuration: 0.1) {
            self.view.alpha = 1.0
            self.view.isUserInteractionEnabled = true
        }
        complainVC.removeFromSuperview()
    }
    
    func agree() {
        UIView.animate(withDuration: 0.1) {
            self.view.alpha = 1.0
            self.view.isUserInteractionEnabled = true
        }
        fbManager.saveComplainUser(postID: idPost, UserID: UserDefaultsModel.shared.getUserUUID())
        getData()
        complainVC.removeFromSuperview()
    }
    
    func getData() {
        if !UserDefaultsModel.shared.checkUserLoggin() {
            fbManager.load() { [self] data in
                DispatchQueue.main.async { [self] in
                    var tempAdvertMass = [AdvertPost]()
                    let group = DispatchGroup()
                    for i in 0..<data.count {
                        group.enter()
                        fbManager.loadComplainUser(postID: data[i].postId) { complain in
                            if complain.isEmpty || !complain.contains(UserDefaultsModel.shared.getUserUUID()) {
                                let advertPost = AdvertPost(
                                    countComments: data[i].countComments,
                                    postId: data[i].postId,
                                    phoneNumber: data[i].phoneNumber,
                                    linkImage: data[i].linkImage,
                                    typePost: data[i].typePost,
                                    breed: data[i].breed,
                                    postName: data[i].postName,
                                    descriptionName: data[i].descriptionName,
                                    typePet: data[i].typePet,
                                    oldPet: data[i].oldPet,
                                    lostAdress: data[i].lostAdress,
                                    curentDate: data[i].curentDate
                                )
                                tempAdvertMass.append(advertPost)
                            }
                            group.leave()
                        }
                    }
                    group.notify(queue: DispatchQueue.main) { [self] in
                        self.advertMass = tempAdvertMass
                        self.countAllLabel.text = "\(advertMass.count)"
                        self.countCatLabel.text = "\(advertMass.filter { $0.typePet == "Кошка" }.count)"
                        self.countDogLabel.text = "\(advertMass.filter { $0.typePet == "Собака" }.count)"
                        self.countOtherLabel.text = "\(advertMass.filter { $0.typePet == "Другое" }.count)"
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func choiseTypePet(_ sender: UIButton) {
        for button in [allButton, catButton, dogButton, otherButton] as [UIButton?] {
            if button?.tag == sender.tag {
                button?.tintColor = UIColor.systemBlue
                switch sender.tag {
                case 0:
                    getMassiveCriteria(type: "all")
                case 1:
                    getMassiveCriteria(type: "Собака")
                case 2:
                    getMassiveCriteria(type: "Кошка")
                default:
                    getMassiveCriteria(type: "Другое")
                }
            } else {
                button?.tintColor = UIColor.label
            }
        }
    }
    
    func getMassiveCriteria(type: String) {
        if type == "all" {
            samplingMass.removeAll()
            checkCtriteria = false
            getData()
        } else {
            samplingMass.removeAll()
            checkCtriteria = true
            for i in advertMass {
                if i.typePet == type {
                    samplingMass.append(i)
                }
            }
            tableView.reloadData()
        }
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
        if !checkCtriteria {
            let text = searchText.lowercased()
            filterMass = advertMass.filter { $0.postName.lowercased().contains(text) }
            searching = true
            tableView.reloadData()
        } else {
            let text = searchText.lowercased()
            filterMass = samplingMass.filter { $0.postName.lowercased().contains(text) }
            searching = true
            tableView.reloadData()
        }

    }
}

extension AdvertViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching {
            if filterMass.indices.contains(indexPath.row) {
                let adverpage = AdvertPageViewController.instantiate()
                let navigationController = UINavigationController(rootViewController: adverpage)
                navigationController.modalPresentationStyle = .fullScreen
                adverpage.updateUIElements(filterMass[indexPath.row].postId)
                present(navigationController, animated: true)
            }
        } else if checkCtriteria {
            let adverpage = AdvertPageViewController.instantiate()
            let navigationController = UINavigationController(rootViewController: adverpage)
            navigationController.modalPresentationStyle = .fullScreen
            adverpage.updateUIElements(samplingMass[indexPath.row].postId)
            present(navigationController, animated: true)
        } else {
            if advertMass.indices.contains(indexPath.row) {
                let adverpage = AdvertPageViewController.instantiate()
                let navigationController = UINavigationController(rootViewController: adverpage)
                navigationController.modalPresentationStyle = .fullScreen
                adverpage.updateUIElements(advertMass[indexPath.row].postId)
                present(navigationController, animated: true)
            }
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
        } else if checkCtriteria {
            if samplingMass.isEmpty {
                return 1
            } else {
                return samplingMass.count
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
        if advertMass.isEmpty && filterMass.isEmpty && samplingMass.isEmpty {
            var cell: NoPostTableViewCell
            if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "NoPostTableViewCell") as? NoPostTableViewCell {
                cell = reuseCell
            } else {
                cell = NoPostTableViewCell()
            }
            return configure(cell: cell, for: indexPath)
        } else if (filterMass.count == 0 && searching) || (samplingMass.isEmpty && checkCtriteria) {
            var cell: NoPostTableViewCell
            if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "NoPostTableViewCell") as? NoPostTableViewCell {
                cell = reuseCell
            } else {
                cell = NoPostTableViewCell()
            }
            return configure(cell: cell, for: indexPath)
        } else {
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
                let resurse = ImageResource(downloadURL: URL(string: filterMass[indexPath.row].linkImage.first!)!, cacheKey: filterMass[indexPath.row].linkImage.first)
                DispatchQueue.main.async { [self] in
                    cell.postImageView.kf.setImage(with: resurse)
                    cell.postName.text = filterMass[indexPath.row].postName
                    cell.oldPet.text = "Возраст: \(filterMass[indexPath.row].oldPet)"
                    cell.breed.text = "Порода: \(filterMass[indexPath.row].breed)"
                    cell.lostAdress.text = filterMass[indexPath.row].lostAdress
                    cell.button.tag = indexPath.row
                    cell.delegate = self
                }
            }
        } else if checkCtriteria {
            DispatchQueue.global().async { [self] in
                let resurse = ImageResource(downloadURL: URL(string: samplingMass[indexPath.row].linkImage.first!)!, cacheKey: samplingMass[indexPath.row].linkImage.first!)
                DispatchQueue.main.async { [self] in
                    cell.postImageView.kf.setImage(with: resurse)
                    cell.postName.text = samplingMass[indexPath.row].postName
                    cell.oldPet.text = "Возраст: \(samplingMass[indexPath.row].oldPet)"
                    cell.breed.text = "Порода: \(samplingMass[indexPath.row].breed)"
                    cell.lostAdress.text = samplingMass[indexPath.row].lostAdress
                    cell.button.tag = indexPath.row
                    cell.delegate = self
                }
            }
        } else {
            DispatchQueue.global().async { [self] in
                let resurse = ImageResource(downloadURL: URL(string: advertMass[indexPath.row].linkImage.first!)!, cacheKey: advertMass[indexPath.row].linkImage.first!)
                DispatchQueue.main.async { [self] in
                    cell.postImageView.kf.setImage(with: resurse)
                    cell.postName.text = advertMass[indexPath.row].postName
                    cell.oldPet.text = "Возраст: \(advertMass[indexPath.row].oldPet)"
                    cell.breed.text = "Порода: \(advertMass[indexPath.row].breed)"
                    cell.lostAdress.text = advertMass[indexPath.row].lostAdress
                    cell.button.tag = indexPath.row
                    cell.delegate = self
                }
            }
            
        }
        return cell
    }
}
