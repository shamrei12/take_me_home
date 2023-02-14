//
//  ForgotPasswordViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 8.02.23.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var restorePassword: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func restorePassTapped(_ sender: UIButton) {
        if !emailText.text!.isEmpty {
            Auth.auth().sendPasswordReset(withEmail: emailText.text ?? "") { error in
                if error == nil {
                    self.dismiss(animated: true)
                } else {
                    print(error)
                }
            }
        }
    }
}


