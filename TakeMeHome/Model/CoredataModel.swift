//
//  CoredataModel.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 5.03.23.
//

import CoreData
import UIKit


protocol CoreDataProtocol {
    //    func load() -> [LostPet]
    //    func save(data: [LostPet])
}


class CoreDataClass: CoreDataProtocol {
    
    enum AdvertKey {
        case idPost
    }
    
    func getUUID() -> String {
        return UUID().uuidString
    }
    
    func saveID(_ id: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.newBackgroundContext()
        let entity = NSEntityDescription.entity(forEntityName: "Advert", in: context)
        
        guard let entity = entity else {
            return
        }
        
        let taskObject = NSManagedObject(entity: entity, insertInto: context) as! Advert

        taskObject.idPost = id
        
        do {
            try context.save()
            print(true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
//    func load() -> String {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let fetchRequest: NSFetchRequest<Advert>
//        fetchRequest = Advert.fetchRequest()
//        let context = appDelegate.persistentContainer.viewContext
//        let objects = try! context.fetch(fetchRequest)
//
//
//
//    }
}
