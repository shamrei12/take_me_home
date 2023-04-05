//
//  ExitTableViewCell.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 22.03.23.
//

import UIKit
import FirebaseAuth

class ExitTableViewCell: UITableViewCell {
    

    @IBOutlet weak var exitButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        exitButton.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func exitTapped(_ sender: UIButton) {
        do {
            try  Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
}
