//
//  CoredataModel.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 5.03.23.
//

import CoreData
import UIKit


protocol CoreDataProtocol {
    func getUUID() -> String
}


class CoreDataClass: CoreDataProtocol {
    func getUUID() -> String {
        return UUID().uuidString
    }
    
}
