//
//  RergisterViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 7.02.23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


class RergisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var repeatPasswordText: UITextField!
    private var moveTextField = true
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        passwordText.delegate = self
        repeatPasswordText.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        var contentInsets = scrollView.contentInset
        contentInsets.bottom = -(textField.frame.maxY - scrollView.frame.height + 10) / 1.3
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
    
    @IBAction func registrationTapped(_ sender: UIButton) {
        if !nameText.text!.isEmpty && !emailText.text!.isEmpty && !passwordText.text!.isEmpty && !repeatPasswordText.text!.isEmpty {
            Auth.auth().createUser(withEmail: emailText.text ?? "", password: passwordText.text ?? "") { [self] (result, error) in
                if error == nil {
                    if let res = result {
                        let ref = Database.database().reference().child("users")
                        ref.child(res.user.uid).updateChildValues(["name": nameText.text ?? "", "email" : emailText.text ?? "", "password": passwordText.text ?? "" ])
                        self.dismiss(animated: true)
                    }
                } else {
                    print(error as Any)
                }
                
            }
        }
    }
}
