//
//  Staff.swift
//  App
//
//  Created by Denis Zubkov on 18/10/2019.
//

import Fluent
import FluentMySQL
import Vapor

struct Staff: Content {
    var id: UUID?
    var kod: String
    var name: String
    var staffTypeKod: String
}

extension Staff: MySQLUUIDModel {}
extension Staff: Migration {
}
