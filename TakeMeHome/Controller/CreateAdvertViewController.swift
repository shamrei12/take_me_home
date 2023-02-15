//
//  CreateAdvertViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 15.02.23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase



class CreateAdvertViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak private var postName: UITextField!
    @IBOutlet weak private var breed: UITextField!
    @IBOutlet weak private var old: UITextField!
    @IBOutlet weak private var adress: UITextField!
    @IBOutlet weak private var number: UITextField!
    @IBOutlet weak private var descriptionText: UITextField!
    
    @IBOutlet weak var postType: UISegmentedControl!
    
    private var height: Double = 0.0
    private var userDefaults: UserDefaults?
    private var key: String = "id"
    private var fireBase: FirebaseData?
    private var typePostText: String = ""
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        fireBase = FirebaseData()
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
        } else if number.isEditing {
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
        posts.append(AdvertPost(typePost: typePostText ?? "", breed: breed.text ?? "", postName: postName.text ?? "", descriptionName: descriptionText.text ?? "", typePet: "Dog", oldPet: old.text ?? "", lostAdress: adress.text ?? "", curentDate: TimeManager.shared.currentDate()))
        fireBase?.save(posts: posts)
        dismiss(animated: true)
    }
    
}
