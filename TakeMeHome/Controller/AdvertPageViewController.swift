//
//  AdvertPageViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 18.02.23.
//

import UIKit
import Kingfisher

class AdvertPageViewController: UIViewController {
    
    
    @IBOutlet weak var postID: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var advertImage: UIImageView!
    @IBOutlet weak var postName: UILabel!
    @IBOutlet weak var oldPet: UILabel!
    @IBOutlet weak var descriptionPost: UILabel!
    @IBOutlet weak var breedPet: UILabel!
    @IBOutlet weak var lostAdress: UILabel!
    @IBOutlet weak var numberPhone: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendMessage: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    func updateUIElements(_ data: [AdvertProtocol]) {
        
        DispatchQueue.global().async {
            let resurse = ImageResource(downloadURL: URL(string: data.first?.linkImage ?? "")!)
            DispatchQueue.main.async {
                self.advertImage.kf.setImage(with: resurse)
                self.postID.text = data.first?.typePost
                self.date.text = data.first?.curentDate
                self.postName.text = data.first?.postName
                self.descriptionPost.text = data.first?.descriptionName
                self.oldPet.text = "Возраст: \(data.first?.oldPet ?? "")"
                self.breedPet.text = "Порода: \(data.first?.breed ?? "")"
                self.lostAdress.text = "Адрес: \(data.first?.lostAdress ?? "")"
                self.numberPhone.text = data.first?.phoneNumber
            }
        }

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
