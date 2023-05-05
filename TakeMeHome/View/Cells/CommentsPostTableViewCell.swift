//
//  CommentsPostTableViewCell.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 25.02.23.
//

import UIKit

class CommentsPostTableViewCell: UITableViewCell {

    @IBOutlet weak var nameUser: UILabel!
    
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var textComment: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 10
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
