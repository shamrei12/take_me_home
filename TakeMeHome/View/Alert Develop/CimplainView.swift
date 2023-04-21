//
//  CimplainView.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 21.04.23.
//

import UIKit

class CimplainView: UIView {

    @IBOutlet weak var agreeButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var delegate: Complain?
    override func awakeFromNib() {
        self.layer.cornerRadius = 10
    }
    
    @IBAction func agreeTapped(_ sender: UIButton) {
        delegate?.agree()
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        delegate?.cancel()
    }
}
