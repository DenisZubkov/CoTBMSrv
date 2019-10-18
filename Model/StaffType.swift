//
//  StaffType.swift
//  App
//
//  Created by Denis Zubkov on 18/10/2019.
//

import Fluent
import FluentMySQL
import Vapor

struct StaffType: Content {
    var id: UUID?
    var kod: String
    var name: String
}

extension StaffType: MySQLUUIDModel {}
extension StaffType: Migration {
}
