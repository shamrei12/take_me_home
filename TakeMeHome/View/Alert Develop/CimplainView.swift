//
//  CimplainView.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 21.04.23.
//

import UIKit

class CimplainView: UIView {

    @IBOutlet weak var agreeButton: UIButton!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var delegate: Complain?
    override func awakeFromNib() {
        createUIElement()
    }
    
    
    func createUIElement() {
        self.layer.cornerRadius = 10
        labelView.layer.cornerRadius = 10
        buttonsView.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.3
        agreeButton.layer.cornerRadius = 10
        agreeButton.layer.borderWidth = 1
        agreeButton.titleLabel?.textColor = UIColor.white
        agreeButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.cornerRadius = 10
        
    }
    @IBAction func agreeTapped(_ sender: UIButton) {
        delegate?.agree()
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        delegate?.cancel()
    }
}
