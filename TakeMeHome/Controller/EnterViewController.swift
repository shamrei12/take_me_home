//
//  EnterViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 7.02.23.
//

import UIKit
import FirebaseAuth
import FirebaseCore

class EnterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
        
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }

    
    @objc func keyboardWillShow(notification: NSNotification) {
//            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                if self.view.frame.origin.y == 0 {
//                    self.view.frame.origin.y -= keyboardSize.height
//                }
//            }

        if emailField.isEditing || passwordField.isEditing {
             moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.bottomConstraint, keyboardWillShow: true)
         }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//        }
        moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.bottomConstraint, keyboardWillShow: false)
    }
    
    func moveViewWithKeyboard(notification: NSNotification, viewBottomConstraint: NSLayoutConstraint, keyboardWillShow: Bool) {
        // Keyboard's size
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height

        // Keyboard's animation duration
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double

        // Keyboard's animation curve
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!

        // Change the constant
        if keyboardWillShow {
            let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0) // Check if safe area exists
            let bottomConstant: CGFloat = 40
            viewBottomConstraint.constant = keyboardHeight + (safeAreaExists ? 0 : bottomConstant)
        } else {
            viewBottomConstraint.constant = 40
        }

        // Animate the view the same way the keyboard animates
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            // Update Constraints
            self?.view.layoutIfNeeded()
        }

        // Perform the animation
        animator.startAnimation()
    }
    
    @IBAction func enterTapped(_ sender: UIButton) {
        if emailField.text ?? "" != "" && passwordField.text ?? "" != "" {
            Auth.auth().signIn(withEmail: emailField.text ?? "", password: passwordField.text ?? "") { (result, error) in
                if error == nil {
                    let advertpage = AdvertViewController.instantiate()
                    advertpage.modalPresentationStyle = .fullScreen
                    self.present(advertpage, animated: true)
                }
            }
        }
    }
    
    @IBAction func reristerButtonTapped(_ sender: UIButton) {
        let registerForm = RergisterViewController.instantiate()
        registerForm.modalPresentationStyle = .formSheet
        self.present(registerForm, animated: true)
    }
    
    @IBAction func ForgotPasswordTapped(_ sender: UIButton) {
        let forgotPass = ForgotPasswordViewController.instantiate()
        forgotPass.modalPresentationStyle = .formSheet
        self.present(forgotPass, animated: true)
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
