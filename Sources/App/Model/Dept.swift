//
//  Dept.swift
//  App
//
//  Created by Denis Zubkov on 18/10/2019.
//

import Fluent
import FluentMySQL
import Vapor

struct Dept: Content {
    var id: UUID?
    var address: String
    var countSotrud: Int32
    var email: String
    var gpsX: Double
    var gpsY: Double
    var kod: String
    var name: String
    var noShow: Bool
    var parentId: String
    var phone: String
    var subDept: Int32
    var timeZone: String
}

extension Dept: MySQLUUIDModel {}
extension Dept: Migration {
}
