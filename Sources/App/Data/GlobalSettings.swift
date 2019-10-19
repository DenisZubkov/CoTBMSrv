//
//  GlobalSettings.swift
//  App
//
//  Created by Dennis Zubkoff on 18.10.2019.
//


import Foundation
import Routing
import Vapor


class GlobalSettings {
    let scheme = "http"
    let host = "tbm.tbm.ru"
    let port = 8780
    let server = "/employee"
    let site = "https://tbm.ru"
    let phoneFirst = "tel://+7(495)995-39-32"
    let phoneSecond = "tel://+7(495)662-63-43"
    let address = "141006, Московская область, г. Мытищи, Волковское шоссе, вл. 15, стр. 1"
    let email = "tbm@tbm.ru"
    let gpsX: Double = 55.932049
    let gpsY: Double = 37.740779
    let emptyId = "00000000-0000-0000-0000-000000000000"
    let facebook = "https://www.facebook.com/tbmcompany/"
    let facebookApp = "fb://tbmcompany"
    let icq = ""
    let skype = ""
    var currencySymbol: String = "₽"
    var mainPriceType: String = "Розничная (руб)"
    var specialPriceType: String = "Спеццена"
    

    
    var arrayURL: [URLComponents] = []
    
    func getUrlComponents(table: String) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = server + table
        return urlComponents
    }
    
    func separatedNumber(_ number: Any) -> String {
        guard let itIsANumber = number as? NSNumber else { return "Not a number" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = ","
        return formatter.string(from: itIsANumber)!
    }
    
    func printDate(dateBegin: Date, dateEnd: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        dateFormatter.locale = Locale.init(identifier: "ru_RU")
        let date1 = dateFormatter.string(from: dateBegin)
        let date2 = dateFormatter.string(from: dateEnd)
        let interval = dateEnd.timeIntervalSince(dateBegin)
        print("\(date1) \(date2) \(interval)")
    }
    
    func convertStringToDate(from dateString: String?) -> Date? {
        guard let str = dateString else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale.init(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: str)
    }
    
    func getStringFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }
    
    func getAgesFrom(date: Date, to dateEnd: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month], from: date, to: dateEnd)
        if let year = components.year {
            return String(year)
        }
        return ""
    }
    
    func saveLoadLog(date: Date, name: String, description: String?, value: Int?, time: Double?, req: DatabaseConnectable) {
        let loadLogDB = LoadLog.init(id: nil, date: date, name: name, description: description, Value: value, time: time)
        let _ = loadLogDB.save(on: req)
        
    }
}

enum SortList: String, CaseIterable {
    case alphbetUp = "По алфавиту A..Z"
    case alphbetDown = "По алфавиту Z..А"
    case priceUp = "Сначала дешевые"
    case priceDown = "Сначала дорогие"
    
    var image: String {
        switch self {
        case .alphbetUp : return "sortAlphabetUp"
        case .alphbetDown : return "sortAlphabetDown"
        case .priceUp : return "sortPriceUp"
        case .priceDown : return "sortPriceDown"
        }
    }
    
    init?(id : Int) {
        switch id {
        case 1: self = .alphbetUp
        case 2: self = .alphbetDown
        case 3: self = .priceUp
        case 4: self = .priceDown
        default: return nil
        }
    }
}



