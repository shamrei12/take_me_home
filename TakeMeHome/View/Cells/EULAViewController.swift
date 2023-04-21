//
//  EULAViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 21.04.23.
//

import UIKit

class EULAViewController: UIViewController {
    
    
    @IBOutlet weak var acceptedButton: UIButton!
    var delegate: FirstStartDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        acceptedButton.layer.cornerRadius = 10
        
    }
    
    @IBAction func acceptedTapped(_ sender: UIButton) {
        delegate?.cancelScene()
        self.dismiss(animated: true)
        self.removeFromParent()
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
