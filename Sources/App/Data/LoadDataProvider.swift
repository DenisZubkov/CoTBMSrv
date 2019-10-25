//
//  LoadDataProvider.swift
//  App
//
//  Created by Dennis Zubkoff on 18.10.2019.
//

import Foundation
import Routing
import Vapor
import Fluent
import FluentMySQL



class LoadDataProvider {
    
    let globalSettings = GlobalSettings()
    let dataProvider = DataProvider()
    var dateBegin = Date()
    var depts: [Dept] = []
    var sotruds: [Sotrud] = []
    var genders: [Gender] = []
    var staffTypes: [StaffType] = []
    var staffs: [Staff] = []
    var logOperation: Int = 1
    var deptData: [DeptJSON] = []
    var sotrudData: [Int64 : [SotrudJSON]] = [:]
    
    
    func getJSONObject<T : Decodable>(from data: Data) -> T? {
        if let dataString = String(data: data, encoding: .utf8) {
            let jsonData = Data(dataString.utf8)
            do {
                let jsonObject = try JSONDecoder().decode(T.self, from: jsonData)
                return jsonObject
                
            } catch let error as NSError {
                print(error.localizedDescription)
                print(dataString)
                return nil
            }
        }
        return nil
    }
    
    func getJSONArray<T : Decodable>(from data: Data) -> [T]? {
        if let dataString = String(data: data, encoding: .utf8) {
            let jsonData = Data(dataString.utf8)
            do {
                let jsonObject = try JSONDecoder().decode([T].self, from: jsonData)
                return jsonObject
                
            } catch let error as NSError {
                print(error.localizedDescription)
                print(dataString)
                return nil
            }
        }
        return nil
    }
    
    func checkConnection(req: DatabaseConnectable) {
        let urlComponent = globalSettings.getUrlComponents(table: "/departments")
        guard let url = urlComponent.url else { return }
        dataProvider.check(url: url) { (string) in
            self.globalSettings.saveLoadLog(date: Date(), name: "Проверка соединения с WEB", description: "\(string ?? "Ошибка")", value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
            self.logOperation += 1
        }
    }
    
    func loadDeptDataFromWeb(req: DatabaseConnectable) {
        self.globalSettings.saveLoadLog(date: Date(), name: "Загрузка данных из WEB", description: nil, value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
        self.logOperation += 1
        
        if let data = dataProvider.loadDataFromFile(fileName: "flag", fileExt: "txt") {
            let isLoad = String(decoding: data, as: UTF8.self)
            if isLoad == "1" { return }
        }
        if let dataString = "1".data(using: .utf8) {
            let _ = dataProvider.saveDataToFile(fileName: "flag", fileExt: "txt", data: dataString)
        }

        let urlComponent = globalSettings.getUrlComponents(table: "/departments")
        guard let url = urlComponent.url else { return }
        self.sotrudData = [:]
        self.dataProvider.downloadData(url: url) { data in
            guard let data = data else {
                self.globalSettings.saveLoadLog(date: Date(), name: "Загрузка Dept из WEB", description: "Ошибка: нет данных", value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
                self.logOperation += 1
                return
            }
            let deptsJSON: [DeptJSON]? = self.getJSONArray(from: data)
            
            guard let depts = deptsJSON else {
                self.globalSettings.saveLoadLog(date: Date(), name: "Загрузка Dept из WEB", description: "Ошибка: разбор JSON", value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
                self.logOperation += 1
                return
            }
            self.deptData = depts
            self.globalSettings.saveLoadLog(date: Date(), name: "Загрузка Dept из WEB завершена", description: "Ок", value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
                       self.logOperation += 1
            
            var i = 0
            var cnt = 0
            self.loadSotrudDataFromWeb(depts: depts, i: &i, cnt: &cnt, req: req)
            self.globalSettings.printDate(dateBegin: self.dateBegin, dateEnd: Date())
        }
    }
        
    func loadSotrudDataFromWeb(depts: [DeptJSON], i: inout Int, cnt: inout Int, req: DatabaseConnectable) {
        guard let deptId = depts[i].id else {
            self.globalSettings.saveLoadLog(date: Date(), name: "Загрузка Sotrud из WEB", description: "Ошибка: нет DeptId", value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
            self.logOperation += 1
            return
        }
        let urlComponent = globalSettings.getUrlComponents(table: "/departments/\(deptId)/employees")
        guard let url = urlComponent.url else {
            self.globalSettings.saveLoadLog(date: Date(), name: "Загрузка Sotrud из WEB", description: "Ошибка URL: \(urlComponent.url?.absoluteString ?? "Нет URL")", value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
            self.logOperation += 1
            return
        }
        var index = i
        var cntIndex = cnt
        dataProvider.downloadData(url: url) { data in
            guard let data = data else {
                self.globalSettings.saveLoadLog(date: Date(), name: "Загрузка Sotrud из WEB", description: "Ошибка: нет данных \(url.absoluteString)", value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
                self.logOperation += 1
                return
            }
            let sotrudsJSON: [SotrudJSON]? = self.getJSONArray(from: data)
            guard var sotruds = sotrudsJSON else {
                self.globalSettings.saveLoadLog(date: Date(), name: "Загрузка Sotrud из WEB", description: "Ошибка: разбор JSON \(deptId)", value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
                self.logOperation += 1
                return
            }
            sotruds = sotruds.filter({$0.dateDismissal == nil })
            self.sotrudData[deptId] = sotruds
            for _ in sotruds {
                cntIndex += 1
            }
            index += 1
            if index < depts.count {
                self.loadSotrudDataFromWeb(depts: depts, i: &index, cnt: &cntIndex, req: req)
            } else {
                self.globalSettings.saveLoadLog(date: Date(), name: "Загрузка Sotrud из WEB завершена", description: "Ok", value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
                self.logOperation += 1
                self.globalSettings.printDate(dateBegin: self.dateBegin, dateEnd: Date())
                self.updateDataFromDB(req: req)
            }
        }
    }
        
        var treeDept1:  [Dept] = []
        
        func seekSubdept(dept: Dept) {
            for currentDept in depts {
                if currentDept.parentId == dept.kod && currentDept.noShow == false {
                    treeDept1.append(currentDept)
                    seekSubdept(dept: currentDept)
                }
            }
        }
        
        func countSotrudInDept(dept:Dept) ->Int {
            if treeDept1.count != 0 {
                treeDept1.removeAll()
            }
            treeDept1.append(dept)
            seekSubdept(dept: dept)
            var count = 0
            for currentDept in treeDept1 {
                for currentSotrud in sotruds {
                    if currentSotrud.deptKod == currentDept.kod {
                        count += 1
                    }
                }
            }
            return count
        }
        
    func fillSubDept(req: DatabaseConnectable) {
            var count = 0
            for dept in self.depts {
                var dept = dept
                dept.countSotrud = Int32(countSotrudInDept(dept: dept))
                if dept.countSotrud == 0 {
                    dept.subDept = Int32(treeDept1.count - 1)
                    dept.noShow = true
                }
                dept.subDept = Int32(treeDept1.count - 1)
                let _ = dept.save(on: req)
                treeDept1.removeAll()
                count += 1
            }
            for dept in depts {
                var dept = dept
                if treeDept1.count != 0 {
                    treeDept1.removeAll()
                }
                seekSubdept(dept: dept)
                dept.subDept = Int32(treeDept1.count)
                let _ = dept.save(on: req)
            }
        }
        
        func dataMirror(date: String) -> String {
            var year: String = ""
            var month: String = ""
            var day: String = ""
            var indexChar: Int = 0
            
            for char in date {
                indexChar += 1
                if indexChar >= 1  && indexChar <= 4 {
                    year = year + String(char)
                }
                if indexChar >= 6  && indexChar <= 7 {
                    month = month + String(char)
                }
                if indexChar >= 9  && indexChar <= 10 {
                    day = day + String(char)
                }
            }
            
            return day + "." + month + "." + year
        }
    
    func addDeptToDB(dept: DeptJSON) {
        
    }
    
    func addSotrudToDB(sotrud: SotrudJSON, dept: Dept) {
        
    }
    
    func updateDataFromDB(req: DatabaseConnectable) {
        self.globalSettings.saveLoadLog(date: Date(), name: "Загрузка данных из DB", description: nil, value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
        self.logOperation += 1
        let _ = Gender.query(on: req).all().map { results in
            self.genders = results
            let _ = StaffType.query(on: req).all().map { results in
                self.staffTypes = results
                let _ = Staff.query(on: req).all().map { results in
                    self.staffs = results
                    let _ = Dept.query(on: req).all().map { results in
                        self.depts = results
                        let _ = Sotrud.query(on: req).all().map { results in
                            self.sotruds = results
                            self.globalSettings.saveLoadLog(date: Date(), name: "Разбор данных из WEB", description: nil, value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
                            self.logOperation += 1
                            self.parceData(req: req)
                        }
                    }
                }
            }
        }
    }
    
    func checkDBLoad(req: DatabaseConnectable) {
        let _ = Gender.query(on: req).all().map { results in
            self.genders = results
            print("Genders: \(self.genders.count)")
            let _ = StaffType.query(on: req).all().map { results in
                self.staffTypes = results
                print("StaffTypes: \(self.staffTypes.count)")
                let _ = Staff.query(on: req).all().map { results in
                    self.staffs = results
                    print("Staffs: \(self.staffs.count)")
                    let _ = Dept.query(on: req).all().map { results in
                        self.depts = results
                        print("Depts: \(self.depts.count)")
                        let _ = Sotrud.query(on: req).all().map { results in
                            self.sotruds = results
                            print("Sotruds: \(self.sotruds.count)")
                            var i = 0
                            self.loadPhoto(sotruds: self.sotruds, i: &i, req: req)
                            self.fillSubDept(req: req)
                            print("SubDeptFilled.")
                        }
                    }
                }
            }
        }
    }
    
    func parceData(req: DatabaseConnectable) {
        for dept in self.deptData {
            parceDept(deptWeb: dept, req: req)
            guard let deptId = dept.id, let sotrudJSON = sotrudData[deptId] else { continue }
            for sotrud in sotrudJSON {
                parceSotrud(deptKod: String(deptId), sotrudWeb: sotrud, req: req)
            }
            print("Dept: \(dept.name ?? "Не указан")\nSotruds: \(self.sotruds.count)")
        }
        for staffType in self.staffTypes {
            let _ = staffType.save(on: req)
        }
        for staff in self.staffs {
            let _ = staff.save(on: req)
        }
        self.globalSettings.saveLoadLog(date: Date(), name: "Разбор данных из WEB завершен", description: nil, value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
        self.logOperation += 1
        self.globalSettings.printDate(dateBegin: self.dateBegin, dateEnd: Date())
        checkDBLoad(req: req)
        if let dataString = "0".data(using: .utf8) {
            let _ = dataProvider.saveDataToFile(fileName: "flag", fileExt: "txt", data: dataString)
        }
    }
    
    func parceDept(deptWeb: DeptJSON, req: DatabaseConnectable) {
        if let deptId = deptWeb.id {
        let kod = String(deptId)
        let name = deptWeb.name ?? "Не указан"
        let parentId = String(deptWeb.parentId ?? 0)
        let address = deptWeb.adres ?? "Не указан"
        let phone = deptWeb.phone ?? "Не указан"
        let timeZone = String(deptWeb.timeZone ?? 0)
        let gpsX = deptWeb.gpsX ?? 0
        let gpsY = deptWeb.gpsY ?? 0
        let email = deptWeb.email ?? "Не указан"
        if var deptDB = self.depts.filter({$0.kod == kod}).first {
            deptDB.name = name
            deptDB.parentId = parentId
            deptDB.address = address
            deptDB.phone = phone
            deptDB.timeZone = timeZone
            deptDB.gpsX = gpsX
            deptDB.gpsY = gpsY
            deptDB.email = email
            let _ = deptDB.save(on: req)
        } else {
            let deptDB = Dept.init(id: nil,
                                   address: address,
                                   countSotrud: 0,
                                   email: email,
                                   gpsX: gpsX,
                                   gpsY: gpsY,
                                   kod: kod,
                                   name: name,
                                   noShow: false,
                                   parentId: parentId,
                                   phone: phone,
                                   subDept: 0,
                                   timeZone: timeZone)
            let _ = deptDB.save(on: req)
            self.depts.append(deptDB)
            
        }
        }
    }
    
    func parceSotrud(deptKod: String, sotrudWeb: SotrudJSON, req: DatabaseConnectable) {
        if let sotrudId = sotrudWeb.id {
            let kod = String(sotrudId)
            let genderName = sotrudWeb.gender ??  "Не указан"
            let genderKod = parceGender(genderName: genderName, req: req)
            let staffName = sotrudWeb.positionWork ?? "Не указан"
            let staffId = sotrudWeb.positionId ?? 0
            let staffTypeName = sotrudWeb.typePositionName ?? "Не указан"
            let staffTypeId = sotrudWeb.typePositionId ?? 0
            let staffKod = parceStaff(staffName: staffName, staffId: staffId, staffTypeName: staffTypeName, staffTypeId: staffTypeId, req: req)
            let deptKod = deptKod
            let addPhone = sotrudWeb.phone ?? "Не указан"
            let email = sotrudWeb.email ?? "Не указан"
            let firstName = sotrudWeb.name ?? ""
            let lastName = sotrudWeb.surname ?? ""
            let middleName = sotrudWeb.middleName ?? ""
            let mobilePhone = sotrudWeb.mobilePhone ?? "Не указан"
            let room = sotrudWeb.room ?? "Не указан"
            let workPhone = sotrudWeb.workPhone ?? "Не указан"
            let leadership = String(sotrudWeb.leadership ?? 0)
            let birthday = sotrudWeb.birthday ?? ""
            let employmentDate = sotrudWeb.dateRecruitment ?? ""
            let terminationDate = sotrudWeb.dateDismissal ?? ""
            if var sotrudDB = self.sotruds.filter({$0.kod == kod}).first {
                sotrudDB.deptKod = deptKod
                sotrudDB.addPhone = addPhone
                sotrudDB.email = email
                sotrudDB.firstName = firstName
                sotrudDB.lastName = lastName
                sotrudDB.middleName = middleName
                sotrudDB.mobilePhone = mobilePhone
                sotrudDB.room = room
                sotrudDB.workPhone = workPhone
                sotrudDB.leadership = leadership
                sotrudDB.photo = kod
                sotrudDB.birthday = birthday
                sotrudDB.employmentDate = employmentDate
                sotrudDB.terminationDate = terminationDate
                sotrudDB.genderKod = genderKod
                sotrudDB.staffKod = staffKod
                let _ = sotrudDB.save(on: req)
            } else {
                let sotrudDB = Sotrud.init(id: nil,
                                           addPhone: addPhone ,
                                           birthday: birthday,
                                           email: email,
                                           employmentDate: employmentDate,
                                           firstName: firstName,
                                           kod: kod,
                                           lastName: lastName,
                                           leadership: leadership,
                                           middleName: middleName,
                                           mobilePhone: mobilePhone,
                                           photo: kod,
                                           data: nil,
                                           room: room,
                                           terminationDate: terminationDate,
                                           workPhone:workPhone,
                                           deptKod: deptKod,
                                           genderKod: genderKod,
                                           staffKod: staffKod)
                let _ = sotrudDB.save(on: req)
                self.sotruds.append(sotrudDB)
            }
        }
        
    }
    
    func parceGender(genderName: String, req: DatabaseConnectable) -> String {
        var kod = "0"
        if genderName == "мужской" {
            kod = "1"
        } else if genderName == "женский" {
            kod = "2"
        } else {
            kod = "0"
        }
        guard let _ = self.genders.filter({$0.kod == kod}).first  else {
            let genderDB = Gender.init(id: nil, kod: kod, name: genderName)
            let _ = genderDB.save(on: req)
            self.genders.append(genderDB)
            return kod
        }
        return kod
     }
    
    func parceStaff(staffName: String, staffId: Int64, staffTypeName: String, staffTypeId: Int, req: DatabaseConnectable) -> String {
        let kod = String(staffId)
        let staffTypeKod = parceStaffType(staffTypeName: staffTypeName, staffTypeId: staffTypeId, req: req)
        if self.staffs.filter({$0.kod == kod}).first != nil {
            for i in 0..<self.staffs.count {
                if self.staffs[i].kod == kod {
                    self.staffs[i].name = staffName
                    self.staffs[i].staffTypeKod = staffTypeKod
                }
            }
        } else {
            let staffDB = Staff.init(id: nil, kod: kod, name: staffName, staffTypeKod: staffTypeKod)
            self.staffs.append(staffDB)
        }
        
        return kod
    }
    
    func parceStaffType(staffTypeName: String, staffTypeId: Int, req: DatabaseConnectable) -> String {
        let kod = String(staffTypeId)
        if self.staffTypes.filter({$0.kod == kod}).first != nil {
            for i in 0..<self.staffTypes.count {
                if self.staffTypes[i].kod == kod {
                    self.staffTypes[i].name = staffTypeName
                    break
                }
            }
        } else {
            let staffTypeDB = StaffType.init(id: nil, kod: kod, name: staffTypeName)
            self.staffTypes.append(staffTypeDB)
        }
        return kod
    }
    
//    let photoJSON = PhotoJSON.init(kod: photoId, data: data)
//    let encoder = JSONEncoder()
//    do {
//        let dataJSON = try encoder.encode(photoJSON)
//        sotrudDB.data = dataJSON
//        let _ = sotrudDB.save(on: req)
//    } catch {
//        print(error)
//    }
    
    func loadPhoto(sotruds: [Sotrud], i: inout Int, req: DatabaseConnectable) {
        let photoId = sotruds[i].photo
        var sotrudDB = sotruds[i]
        var index = i
        dataProvider.downloadPhoto(id: photoId) { data in
            if let data = data {
                let isLoaded = self.dataProvider.saveDataToFile(fileName: photoId, fileExt: "jpg", data: data)
                sotrudDB.data = data
                let _ = sotrudDB.save(on: req)
                self.globalSettings.saveLoadLog(date: Date(), name: "Фото \(photoId) загружено:", description: "\(isLoaded)", value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
                self.logOperation += 1
            }
            index += 1
            if index < sotruds.count {
                self.loadPhoto(sotruds: sotruds, i: &index, req: req)
            } else {
                self.globalSettings.saveLoadLog(date: Date(), name: "Загрузка фото завершена", description: "Ok", value: self.logOperation, time: Date().timeIntervalSince(self.dateBegin), req: req)
                self.logOperation += 1
            }
            
        }
        
        
    }
}


