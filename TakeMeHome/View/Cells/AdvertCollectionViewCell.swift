//
//  AdvertCollectionViewCell.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 5.02.23.
//

import UIKit

class AdvertCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 10
    }

}
