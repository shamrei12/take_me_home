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
    
    func getFirstLinks(_ strLinks: String) -> String {
        let result = strLinks.components(separatedBy: [" "])
        return result.first ?? ""
    }
    
    func getCountLinks (_ strLinks: String) -> Int {
        let result = strLinks.components(separatedBy: [" "])
        return result.count
    }
    
    func getListLinks (_ strLinks: String) -> [String] {
        var result: [String] = strLinks.components(separatedBy: [" "]).dropLast()
        return result
    }
    
}
