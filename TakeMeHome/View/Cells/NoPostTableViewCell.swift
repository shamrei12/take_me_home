//
//  NoPostTableViewCell.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 12.04.23.
//

import UIKit

class NoPostTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var MessageText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
