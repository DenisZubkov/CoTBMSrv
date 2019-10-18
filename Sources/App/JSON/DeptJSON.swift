//
//  DeptJSON.swift
//  App
//
//  Created by Denis Zubkov on 18/10/2019.
//

import Foundation

struct DeptJSON : Decodable {
    var id: Int64?
    var name: String?
    var parentId: Int64?
    var timeZone: Int?
    var phone: String?
    var email: String?
    var adres: String?
    var gpsX: Double?
    var gpsY: Double?
}
