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
    @IBOutlet weak var postImageView: UIImageView!
    var delegate: Complain?
    let button = UIButton(type: .system)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 10
        createButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    func createButton() {
        button.setImage(UIImage(named: "dots"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            button.topAnchor.constraint(equalTo: self.topAnchor, constant: 16)
        ])

    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        delegate?.complain(sender.tag)
    }
}
