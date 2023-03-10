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

class CreateAdvertViewController: UIViewController, UITextFieldDelegate, PHPickerViewControllerDelegate {

    
    @IBOutlet weak private var postName: UITextField!
    @IBOutlet weak private var breed: UITextField!
    @IBOutlet weak private var cityName: UITextField!
    @IBOutlet weak private var countryPicker: UIButton!
    @IBOutlet weak private var streetName: UITextField!
    @IBOutlet weak private var houseNumber: UITextField!
    @IBOutlet weak private var buildLabel: UITextField!
    
    @IBOutlet weak private var phoneNumber: UITextField!
    @IBOutlet weak private var descriptionText: UITextField!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var postType: UISegmentedControl!
    @IBOutlet weak private var addPhothoButton: UIButton!
    
    @IBOutlet weak var choiseAge: UISegmentedControl!
    
    private var height: Double = 0.0
    private var userDefaults: UserDefaults?
    private var key: String = "id"
    private var fireBase: FirebaseData?
    private var coreData: CoreDataClass!
    private var typePostText: String = ""
    private var agePet: String = ""
    private var typePet: String = ""
    
    @IBOutlet private weak var scrollView: UIScrollView!
    private var imageStorage: [Data] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        addPhothoButton.layer.cornerRadius = 10
        fireBase = FirebaseData()
        coreData = CoreDataClass()
        choiceType()
        collectionView.register(UINib(nibName: "AddPhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AddPhotoCollectionViewCell")
        askPermision()
        phoneNumber.delegate = self
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
    
    func formattedNumber(number: String) -> String {
        
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "+###(##)#######"
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "#" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string:  String) -> Bool {
        if phoneNumber.isEditing {
            let  char = string.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            if ((isBackSpace == -92) && (textField.text?.count)! > 0) {
                textField.text!.removeLast()
            } else {
                textField.text = formattedNumber(number: newString)
            }
           return false
        }
        return true
    }
    
    
    @IBAction func addPhotoTapped(_ sender: UIButton) {
        showPhotoLibrary()
    }
    
    @IBAction func choseTipePost(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            typePostText = "Пропажа"
        } else if sender.selectedSegmentIndex == 1 {
            typePostText = "Находка"
        } else {
            typePostText = "Из рук в Руки"
        }
    }
    
    @IBAction func choiseTypePet(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            typePet = "Собака"
        } else if sender.selectedSegmentIndex == 1 {
            typePet = "Кошка"
        } else if sender.selectedSegmentIndex == 2 {
            typePet = "Другое"
        }
    }
    
    
    @IBAction func choiseAge(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            agePet = "До 1 года"
        } else if sender.selectedSegmentIndex == 1 {
            agePet = "От 1 до 3 лет"
        } else if sender.selectedSegmentIndex == 2 {
            agePet = "3 года и старше"
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if cityName.isEditing {
            height = 250
        } else if breed.isEditing {
            height = 80
        } else if houseNumber.isEditing || streetName.isEditing || buildLabel.isEditing {
            height = 330
        } else if phoneNumber.isEditing {
            height = 380
        } else if descriptionText.isEditing {
            height = 520
        }
        scrollView.setContentOffset(CGPointMake(0, height), animated: true)
    }
    
    func createAdress() -> String {
        
        if buildLabel.text!.count > 0 {
            return "\(countryPicker.titleLabel?.text ?? ""), \(cityName.text ?? ""), ул. \(streetName.text ?? ""), \(houseNumber.text ?? ""), к\(buildLabel.text ?? "")"
        } else {
            return "\(countryPicker.titleLabel?.text ?? ""), \(cityName.text ?? ""), ул. \(streetName.text ?? ""), \(houseNumber.text ?? "")"
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        height /= 2
        scrollView.setContentOffset(CGPointMake(0, height), animated: true)
    }
    
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func savePostTapped(_ sender: UIBarButtonItem) {
        var posts: [AdvertProtocol] = []
        if typePostText == "" {
            typePostText = "Пропажа"
        }
        
        if typePet == "" {
            typePet = "Собака"
        }
        
        posts.append(AdvertPost(countComments: "0", postId: "", phoneNumber: phoneNumber.text ?? "", linkImage: "", typePost: typePostText , breed: breed.text ?? "", postName: postName.text ?? "", descriptionName: descriptionText.text ?? "", typePet: typePet, oldPet: agePet , lostAdress: createAdress() , curentDate: TimeManager.shared.currentDate()))
        let postID = coreData.getUUID()
        coreData.saveID(postID)
        fireBase?.saveIDPostUser(id: postID)
        fireBase?.save(posts: posts, id: postID, stroage: imageStorage)
        dismiss(animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for item in results {
            item.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    DispatchQueue.global().async {
                        self.imageStorage.append(Data(image.pngData()!))
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        
                    }
                }
            }
        }
        dismiss(animated: true)
    }
    
    func choiceType() {
        let optionClousure = {(action: UIAction) in
            print(action.title)
        }
        countryPicker.menu = UIMenu(children: [
            UIAction(title: "Выберете страну", state: .on, handler: optionClousure),
                        UIAction(title: "Беларусь", handler: optionClousure)
        ])
        
        countryPicker.showsMenuAsPrimaryAction = true
        countryPicker.changesSelectionAsPrimaryAction = true
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

