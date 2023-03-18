//
//  AlertInDevelop.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 14.03.23.
//

import UIKit

class AlertInDevelop: UIView {
    
    var delegate: AlertDelegate?
    @IBOutlet weak var buttonTapped: UIButton!
    
    override func awakeFromNib() {
          super.awakeFromNib()
        buttonTapped.layer.cornerRadius = 10
        self.layer.cornerRadius = 10
      }
    
    
    @IBAction func cancelSceneTapped(_ sender: UIButton) {
        delegate?.cancelScene()
    }
}
