//
//  AdvertViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 4.02.23.
//

import UIKit

class AdvertViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuButton.layer.cornerRadius = 5
        mapButton.layer.cornerRadius = 5
        tableView.register(UINib(nibName: "AdvertTableViewCell", bundle: nil), forCellReuseIdentifier: "AdvertTableViewCell")
        collectionView.register(UINib(nibName: "AdvertCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AdvertCollectionViewCell")
        
    }
}

extension AdvertViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: AdvertTableViewCell
          if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "AdvertTableViewCell") as? AdvertTableViewCell {
              cell = reuseCell
          } else {
              cell = AdvertTableViewCell()
          }
          
          return configure(cell: cell, for: indexPath)
    }
    
    private func configure(cell: AdvertTableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        return cell
    }
}


extension AdvertViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         var cell: AdvertCollectionViewCell
         if let reuseCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdvertCollectionViewCell", for: indexPath) as? AdvertCollectionViewCell {
             cell = reuseCell
         } else {
             cell = AdvertCollectionViewCell()
         }
         return configure(cell: cell, for: indexPath)
     }
     
     private func configure(cell: AdvertCollectionViewCell, for indexPath: IndexPath) -> UICollectionViewCell {
         return cell
 }
    
}


