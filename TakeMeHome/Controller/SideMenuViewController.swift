//
//  SideMenuViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 8.02.23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableSideMenu: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = nil
        tableSideMenu.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "SideMenuTableViewCell")
        tableSideMenu.register(UINib(nibName: "ExitTableViewCell", bundle: nil), forCellReuseIdentifier: "ExitTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageView.image = UIImage(named: "appLogo")
    }
    override func viewWillDisappear(_ animated: Bool) {
        imageView.image = nil
    }
}

extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
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

           } else if indexPath.row == 1 {
               cell.imageCell.image = UIImage(named: "profile.png")
               cell.labelCell.text = "Профиль"
           }
//        else if indexPath.row == 2 {
//               do {
//                   try  Auth.auth().signOut()
//               } catch {
//                   print(error)
//               }
//           }
           return cell
       }
    }
    
extension SideMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let profile = ProfileViewController.instantiate()
            profile.modalPresentationStyle = .fullScreen
            present(profile, animated: true)
        } else if indexPath.row == 0 {
            let createAD = CreateAdvertViewController.instantiate()
            createAD.modalPresentationStyle = .fullScreen
            present(createAD, animated: true)
        }
    }
}
