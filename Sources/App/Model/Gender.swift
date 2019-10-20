//
//  Gender.swift
//  App
//
//  Created by Denis Zubkov on 18/10/2019.
//

import Fluent
import FluentMySQL
import Vapor

struct Gender: Content {
    var id: UUID?
    var kod: String
    var name: String
}

extension Gender: MySQLUUIDModel {}
extension Gender: Migration {
}
