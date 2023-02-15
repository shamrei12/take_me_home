//
//  TimeManager.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 15.02.23.
//

import Foundation

import Foundation


class TimeManager {
    
    static var shared: TimeManager = {
        let instance = TimeManager()
        return instance
    }()
    
    
    func currentDate() -> String {
        let date = Date()
        let dateFormater = DateFormatter()
        dateFormater.timeZone = TimeZone(abbreviation: "GMT+3")
        dateFormater.locale = Locale.current
        dateFormater.dateFormat = "dd.MM.yyyy"
        let formattedString = dateFormater.string(from: date)
        return formattedString
    }
}
