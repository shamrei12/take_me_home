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


class RergisterViewController: UIViewController {
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var repeatPasswordText: UITextField!
    private var moveTextField = true
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if moveTextField {
            moveTextField = false
            if passwordText.isEditing || repeatPasswordText.isEditing {
                guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
                let keyboardHeight = keyboardSize.height
                let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0)
                let bottomConstant: CGFloat = 20
                bottomConstraint.constant -= keyboardHeight / 2.1
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //        if self.view.frame.origin.y != 0 {
        //            self.view.frame.origin.y = 0
        //        }
        moveTextField = true
        bottomConstraint.constant = 150
        
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
                    print(error)
                }
                
            }
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
