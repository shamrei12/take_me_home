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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func registrationTapped(_ sender: UIButton) {
        if !nameText.text!.isEmpty && !emailText.text!.isEmpty && !passwordText.text!.isEmpty && !repeatPasswordText.text!.isEmpty {
            Auth.auth().createUser(withEmail: emailText.text ?? "", password: passwordText.text ?? "") { [self] (result, error) in
                if error == nil {
                    if let res = result {
                        print(res.user.uid)
                        let ref = Database.database().reference().child("users")
                        ref.child(res.user.uid).updateChildValues(["name": nameText.text ?? "", "email" : emailText.text ?? "" ])
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
