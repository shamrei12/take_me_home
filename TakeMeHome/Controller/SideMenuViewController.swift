//
//  SideMenuViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 8.02.23.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var tableSideMenu: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSideMenu.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "SideMenuTableViewCell")
        
        // Do any additional setup after loading the view.
    }
    
    //    @IBAction func signOut(_ sender: UIButton) {
    //        do {
    //            try  Auth.auth().signOut()
    //        } catch {
    //            print(error)
    //        }
    //    }
    
}

extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SideMenuTableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as? SideMenuTableViewCell {
            cell = reuseCell
        } else {
            cell = SideMenuTableViewCell()
        }
        
        return configure(cell: cell, for: indexPath)
    }
    
    private func configure(cell: SideMenuTableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            cell.imageCell.image = UIImage(named: "create.png")
            cell.labelCell.text = "Создать объявление"

            cell.constaintSecondView.constant = 50
        } else if indexPath.row == 1 {
            cell.imageCell.image = UIImage(named: "profile.png")
            cell.labelCell.text = "Профиль"
        } else if indexPath.row == 2 {
            cell.imageCell.image = UIImage(named: "messages.png")
            cell.labelCell.text = "Сообщения"
        } else if indexPath.row == 3 {
            cell.imageCell.image = UIImage(named: "notifications.png")
            cell.labelCell.text = "Уведомления"
        } else if indexPath.row == 4 {
            cell.imageCell.image = UIImage(named: "help.png")
            cell.labelCell.text = "Поддержка"
        } else {
            cell.imageCell.image = UIImage(named: "settings.png")
            cell.labelCell.text = "Настройки"
        }
        
        return cell
    }
}

extension SideMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let profile = ProfileViewController.instantiate()
            profile.modalPresentationStyle = .fullScreen
            present(profile, animated: true)
        }
    }
}


