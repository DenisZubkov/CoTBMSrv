//
//  LoadDataProvider.swift
//  App
//
//  Created by Dennis Zubkoff on 18.10.2019.
//

import Foundation
import Routing
import Vapor


class LoadDataProvider {
    
    let globalSettings = GlobalSettings()
    let dataProvider = DataProvider()
    var date = Date()
    
    func checkConnection(req: DatabaseConnectable) {
        let urlComponent = globalSettings.getUrlComponents(table: "/departments")
        guard let url = urlComponent.url else { return }
        dataProvider.check(url: url) { (string) in
            print(string)
            self.globalSettings.saveLoadLog(date: Date(), name: "Check connection", description: "\(string ?? "Failure")", value: 1, time: nil, req: req)
        }
    }
    
    
    
}
