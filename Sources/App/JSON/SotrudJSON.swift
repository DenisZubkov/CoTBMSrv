//
//  SotrudJSON.swift
//  App
//
//  Created by Denis Zubkov on 18/10/2019.
//

import Foundation

struct SotrudJSON : Decodable {
    var id: Int64?
    var numberEmployee: Int?
    var surname: String?
    var name: String?
    var middleName: String?
    var gender: String?
    var birthday: String?
    var dateRecruitment: String?
    var email: String?
    var positionWork: String?
    var phone: String?
    var skype: String?
    var positionId: Int64?
    var workPhone: String?
    var mobilePhone: String?
    var room: String?
    var dateDismissal: String?
    var leadership: Int?
    var typePositionId: Int?
    var typePositionName: String?
    var departmentShortName: String?
    
}
