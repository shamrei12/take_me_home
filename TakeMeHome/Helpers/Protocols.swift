//
//  Protocols.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 14.03.23.
//

import Foundation

protocol AlertDelegate {
 func cancelScene()
}

protocol FirstStartDelegate {
    func cancelScene()
}

protocol Complain {
    func complain(_ index: Int)
    func cancel()
    func agree()
}
