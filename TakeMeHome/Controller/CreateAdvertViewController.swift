//
//  CreateAdvertViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 15.02.23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import PhotosUI
import PhoneNumberKit

class CreateAdvertViewController: UIViewController, UITextFieldDelegate, PHPickerViewControllerDelegate, AlertDelegate {
    @IBOutlet weak private var postName: UITextField!
    @IBOutlet weak private var breed: UITextField!
    @IBOutlet weak private var cityName: UITextField!
    @IBOutlet weak var countryName: UITextField!
    @IBOutlet weak private var streetName: UITextField!
    @IBOutlet weak private var houseNumber: UITextField!
    @IBOutlet weak private var buildLabel: UITextField!
    @IBOutlet weak var userNumber: PhoneNumberTextField!
    @IBOutlet weak private var descriptionText: UITextField!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var postType: UISegmentedControl!
    @IBOutlet weak private var addPhothoButton: UIButton!
    @IBOutlet weak var choiseAge: UISegmentedControl!
    @IBOutlet weak var adressBlock: UIStackView!
    @IBOutlet weak var breedBlock: UIStackView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    private var activityIndicator: UIActivityIndicatorView?
    private var height: Double = 0.0
    private var userDefaults: UserDefaults?
    private var key: String = "id"
    private var fireBase: FirebaseData?
    private var coreData: CoreDataStruct!
    private var typePostText: String = ""
    private var agePet: String = ""
    private var typePet: String = ""
    private var alertView: AlertInDevelop!
    private var imageStorage: [Data] = []
    private var geoCoder: SessionManager!
    private var adressElement: [Geocoder] = []
    private var storage = UserDefaults.standard
    private var storageKey = "login"
    private let phoneNumberKit = PhoneNumberKit()
    private var checkSavePost = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        fireBase = FirebaseData()
        coreData = CoreDataStruct()
        userNumber.addTarget(self, action: #selector(phoneNumberTextFieldDidChange), for: .editingChanged)
        userNumber.delegate = self
        addPhothoButton.layer.cornerRadius = 10
        collectionView.register(UINib(nibName: "AddPhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AddPhotoCollectionViewCell")
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        askPermision()
        userNumber.withFlag = true
        userNumber.withExamplePlaceholder = true
        userNumber.withPrefix = true
        navigationItem.title = "Создать объявление"
        navigationItem.leftBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
    }
    
    @objc func phoneNumberTextFieldDidChange() {
        do {
            let phoneNumber = try phoneNumberKit.parse(userNumber.text!)
            let formattedNumber = phoneNumberKit.format(phoneNumber, toType: .international, withPrefix: true)
            userNumber.text = formattedNumber.replacingOccurrences(of: "[-\\s]", with: "", options: .regularExpression)
        } catch {
            print("Invalid phone number")
        }
    }
    
    
    @objc func  cancelTapped() {
        self.dismiss(animated: true)
    }
    
    
    func changneNumber(phoneNumber: String) -> String {
        return phoneNumber.replacingOccurrences(of: "[-\\s]", with: "", options: .regularExpression)
        
    }
    
    @objc func saveTapped() {
        guard !checkSavePost else { return }
        checkSavePost = true
        
        let user = storage.object(forKey: storageKey) as? String ?? ""
        guard checkCorrectPost() else {
            showAlert(message: "Проверьте заполнены ли все поля и попробуйте еще раз:)")
            checkSavePost = false
            return
        }
        
        var posts: [AdvertProtocol] = []
        if imageStorage.isEmpty {
            if let image = UIImage(named: "no_image.png"), let imageData = image.pngData() {
                imageStorage.append(imageData)
            }
        }
        
        typePostText = typePostText.isEmpty ? "Пропажа" : typePostText
        agePet = agePet.isEmpty ? "До 1 года" : agePet
        typePet = typePet.isEmpty ? "Собака" : typePet
        
        let post = AdvertPost(
            author: UserDefaultsModel.shared.getUserUUID(),
            countComments: "0",
            postId: "",
            phoneNumber: changneNumber(phoneNumber: userNumber.text ?? ""),
            linkImage: [""],
            typePost: typePostText,
            breed: breed.text ?? "",
            postName: postName.text ?? "",
            descriptionName: descriptionText.text ?? "",
            typePet: typePet,
            oldPet: agePet,
            lostAdress: createAdress(),
            curentDate: TimeManager.shared.currentDate()
        )
        posts.append(post)
        
        let postID = coreData.getUUID()
        fireBase?.save(posts: posts, id: postID, stroage: imageStorage) { [self] response in
            DispatchQueue.main.async { [self] in
                if response {
                    DispatchQueue.global().async { [self] in
                        fireBase?.saveIDPostUser(id: postID, login: user)
                        DispatchQueue.main.async { [self] in
                            self.dismiss(animated: true)
                        }
                    }
                } else {
                    showAlert(message: "Произошла ошибка. Проверьте соединение с Интернетом и повторите попытку.")
                }
            }
        }
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
        
        if let lastTextField = scrollView.subviews.last as? UITextField, lastTextField == textField {
            let bottomOffset = CGPoint(x: 0, y: max(scrollView.contentSize.height - scrollView.bounds.size.height, 0))
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    func showPhotoLibrary() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func askPermision() {
        PHPhotoLibrary.requestAuthorization({ status in
            if status == PHAuthorizationStatus.authorized {
                DispatchQueue.main.async {
                    
                }
            } else {
                print("No Access")
            }
        })
    }
    
    func showAlert(message: String) {
        alertView = AlertInDevelop.loadFromNib()
        alertView.delegate = self
        alertView.textAlert.text = message
        UIApplication.shared.keyWindow?.addSubview(alertView)
        alertView.center = CGPoint(x: mainView.frame.size.width  / 2,
                                   y: mainView.frame.size.height / 2)
    }
    
    func cancelScene() {
        alertView.removeFromSuperview()
    }
    
    func checkCorrectPost() -> Bool {
        guard cityName.text?.count != 0,
              streetName.text?.count != 0,
              houseNumber.text?.count != 0,
              breed.text?.count != 0,
              postName.text?.count != 0,
              descriptionText.text?.count != 0,
              userNumber.text?.count != 0 else {
            return false
        }
        return true
    }
    
    @IBAction func addPhotoTapped(_ sender: UIButton) {
        showPhotoLibrary()
    }
    
    func getAdress(type: Int) {
        switch type {
        case 0:
            countryName.text = adressElement.first?.country
            cityName.text = adressElement.first?.city
            streetName.text = adressElement.first?.street
            houseNumber.text = adressElement.first?.houseNumber
        default:
            cityName.text = ""
            streetName.text = ""
            houseNumber.text = ""
        }
    }
    
    func adressFormated(street: String) -> String {
        var str = street
        str = str.replacingOccurrences(of: "улица", with: "")
        str = str.trimmingCharacters(in: .whitespaces)
        return str
    }
    
    @IBAction func getAdress(_ sender: UISwitch) {
        if sender.isOn {
            self.loader.startAnimating()
            LocationManager.shared.getUserLocation { coordinate in
                self.loader.startAnimating()
                if let coordinate = coordinate {
                    let latitude = coordinate.latitude
                    let longitude = coordinate.longitude
                    SessionManager.shared.countryRequest(common: (latitude, longitude)) { completion in
                        DispatchQueue.main.async { [self] in
                            let country = completion.address.country
                            let city = completion.address.city
                            let street = adressFormated(street: completion.address.road ?? "")
                            let houseNumber = completion.address.houseNumber
                            adressElement.append(Geocoder(country: country ?? "", city: city ?? "", street: street, houseNumber: houseNumber ?? "", buildingNumber: ""))
                            getAdress(type: 0)
                        }
                        self.loader.stopAnimating()
                        self.loader.hidesWhenStopped
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.loader.stopAnimating()
                self.loader.hidesWhenStopped
                self.getAdress(type: 1)
            }
        }
    }
    
    @IBAction func choseTipePost(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: typePostText = "Пропажа"
        case 1: typePostText = "Находка"
        default: typePostText = "Из рук в Руки"
        }
    }
    
    @IBAction func choiseTypePet(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: typePet = "Собака"
        case 1: typePet = "Кошка"
        case 2: typePet = "Другое"
        default: break
        }
    }
    
    @IBAction func choiseAge(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: agePet = "До 1 года"
        case 1: agePet = "От 1 до 3 лет"
        case 2: agePet = "3 года и старше"
        default: break
        }
    }
    
    func createAdress() -> String {
        if buildLabel.text!.count > 0 {
            return "\(countryName.text ?? ""), \(cityName.text ?? ""), ул. \(streetName.text ?? ""), \(houseNumber.text ?? ""), к\(buildLabel.text ?? "")"
        } else {
            return "\(countryName.text ?? ""), \(cityName.text ?? ""), ул. \(streetName.text ?? ""), \(houseNumber.text ?? "")"
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for item in results {
            item.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { [weak self] (url, error) in
                guard let self = self, let fileUrl = url else { return }
                do {
                    let imageData = try Data(contentsOf: fileUrl)
                    let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil)!
                    let options: [NSString: Any] = [
                        kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceThumbnailMaxPixelSize: 1280,
                        kCGImageSourceCreateThumbnailWithTransform: true,
                    ]
                    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else { return }
                    DispatchQueue.global(qos: .background).async {
                        let image = UIImage(cgImage: cgImage)
                        if let imageData = image.pngData() {
                            self.imageStorage.append(imageData)
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                } catch {
                    print("Error loading image: \(error.localizedDescription)")
                }
            }
        }
        dismiss(animated: true)
    }
    
}

extension CreateAdvertViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageStorage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: AddPhotoCollectionViewCell
        if let reuseCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCollectionViewCell", for: indexPath) as? AddPhotoCollectionViewCell {
            cell = reuseCell
        } else {
            cell = AddPhotoCollectionViewCell()
        }
        return configure(cell: cell, for: indexPath)
    }
    
    private func configure(cell: AddPhotoCollectionViewCell, for indexPath: IndexPath) -> UICollectionViewCell {
        cell.imageView.image = UIImage(data: imageStorage[indexPath.row])
        return cell
    }
}


