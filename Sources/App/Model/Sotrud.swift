//
//  Sotrud.swift
//  App
//
//  Created by Denis Zubkov on 18/10/2019.
//

import Fluent
import FluentMySQL
import Vapor

struct Sotrud1: Content {
    var id: UUID?
    var addPhone: String
    var birthday: String
    var email: String
    var employmentDate: String
    var firstName: String
    var kod: String
    var lastName: String
    var leadership: String
    var middleName: String
    var mobilePhone: String
    var photo: String
    var data: Data?
    var room: String
    var terminationDate: String
    var workPhone: String
    var deptKod: String
    var genderKod: String
    var staffKod: String
}

extension Sotrud1: MySQLUUIDModel {}
extension Sotrud1: Migration {
}
