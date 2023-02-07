//
//  EnterViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 7.02.23.
//

import UIKit
import FirebaseAuth
import FirebaseCore

class EnterViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func enterTapped(_ sender: UIButton) {
        if emailField.text ?? "" != "" && passwordField.text ?? "" != "" {
            Auth.auth().signIn(withEmail: emailField.text ?? "", password: passwordField.text ?? "") { (result, error) in
                if error == nil {
                    print("1")
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
