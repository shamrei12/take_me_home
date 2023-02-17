//
//  AdvertTableViewCell.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 4.02.23.
//

import UIKit

class AdvertTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var postName: UILabel!
    
    @IBOutlet weak var oldPet: UILabel!
    
    @IBOutlet weak var lostAdress: UILabel!
    @IBOutlet weak var breed: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 10

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
