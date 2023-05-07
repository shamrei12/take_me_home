//
//  ConverterLinks.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 22.02.23.
//

import Foundation

class ConverterLinks {
    static var shared: ConverterLinks = {
        let instance = ConverterLinks()
        return instance
    }()
    
    private init() {}
    
    func getFirstLinks(_ strLinks: [String]) -> String {
        return strLinks.first ?? ""
    }
    
    func getCountLinks (_ strLinks: String) -> Int {
        return strLinks.components(separatedBy: [" "]).count
    }
    
    func getListLinks (_ strLinks: String) -> [String] {
        return strLinks.components(separatedBy: [" "])    }
    
}
