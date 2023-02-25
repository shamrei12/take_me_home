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
    
    
    
    @IBOutlet weak private var postName: UITextField!
    @IBOutlet weak private var breed: UITextField!
    @IBOutlet weak private var old: UITextField!
    @IBOutlet weak private var adress: UITextField!
    @IBOutlet weak private var phoneNumber: UITextField!
    @IBOutlet weak private var descriptionText: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var postType: UISegmentedControl!
    
    @IBOutlet weak var addPhothoButton: UIButton!
    
    private var height: Double = 0.0
    private var userDefaults: UserDefaults?
    private var key: String = "id"
    private var fireBase: FirebaseData?
    private var typePostText: String = ""
    
    @IBOutlet weak var scrollView: UIScrollView!
    private var imageStorage: [Data] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        addPhothoButton.layer.cornerRadius = 10
        fireBase = FirebaseData()
        
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if old.isEditing {
            height = 90
        } else if adress.isEditing {
            height = 170
        } else if phoneNumber.isEditing {
            height = 260
        } else if descriptionText.isEditing {
            height = 380
        }
        scrollView.setContentOffset(CGPointMake(0, height), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        height = 0
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
        posts.append(AdvertPost(postId: "", phoneNumber: phoneNumber.text ?? "", linkImage: "", typePost: typePostText , breed: breed.text ?? "", postName: postName.text ?? "", descriptionName: descriptionText.text ?? "", typePet: "Dog", oldPet: old.text ?? "", lostAdress: adress.text ?? "", curentDate: TimeManager.shared.currentDate()))
        fireBase?.save(posts: posts, stroage: imageStorage)
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

