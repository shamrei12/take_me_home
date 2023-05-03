//
//  UserDefaultsModel.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 3.05.23.
//

import Foundation


class UserDefaultsModel {
    
    static var shared: UserDefaultsModel = {
        let instance = UserDefaultsModel()
        return instance
    }()
    
    private init() {}
    
    private var storage = UserDefaults.standard
    private var storageKey = "login"
    
    
    func checkUserLoggin() -> Bool {
        if storage.object(forKey: storageKey) == nil {
            return true
        } else {
            return false
        }
    }
    
    func getUserUUID() -> String {
        return storage.object(forKey: storageKey) as! String
    }
}
