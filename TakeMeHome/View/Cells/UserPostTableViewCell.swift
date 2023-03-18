//
//  UserPostTableViewCell.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 5.03.23.
//

import UIKit

class UserPostTableViewCell: UITableViewCell {

    @IBOutlet weak var countComments: UILabel!
    @IBOutlet weak var postName: UILabel!
    
    @IBOutlet weak var imagePost: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
