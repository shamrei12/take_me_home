//
//  CommentModel.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 26.02.23.
//

import Foundation

protocol Comments {
    var name: String { get set }
    var comment: String { get set }
}

struct UserComments: Comments {
    var name: String
    var comment: String
}
