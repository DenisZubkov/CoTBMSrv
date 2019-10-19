//
//  DataProvider.swift
//  App
//
//  Created by Dennis Zubkoff on 18.10.2019.
//

import Foundation
import Routing
import Vapor


class DataProvider {

    var dateLastModified: String?
    let globalSettings = GlobalSettings()
    
    func saveDataToFile(fileName: String, fileExt: String, data: Data) -> Bool{
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension(fileExt)
        do {
            try data.write(to: fileURL)
            return true
        } catch {
            return false
        }
    }
    
    
    func downloadPhoto(id: String, completion: @escaping (Data?) -> Void) {
        let table = "/employees/\(id)/photo"
        let urlString = globalSettings.getUrlComponents(table: table)
        guard let url = urlString.url else {
            completion(nil)
            return
        }
        let request = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard error == nil,
                data != nil,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let _ = self else {
                    completion(nil)
                    return
            }
            guard let data = data else {
                completion(nil)
                return
            }
            let _ = self!.saveDataToFile(fileName: "\(id)", fileExt: "jpg", data: data)
            completion(data)
            
        }
        dataTask.resume()
        
    }

    func check(url:URL, completion: @escaping (String?) -> Void) {
        let request = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(error?.localizedDescription)
            }
            guard data != nil else {
                completion("Failure")
                return
            }
            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode != 200 {
                let statusCodeString = String(response.statusCode)
                completion(statusCodeString)
                return
            }
            completion("Ok")
        }
        dataTask.resume()
    }
    
    
    func downloadData(url:URL, completion: @escaping (Data?) -> Void) {
        let request = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(error?.localizedDescription.data(using: .utf8))
            }
            guard let data = data else {
                completion(nil)
                return
            }
            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode != 200 {
                let statusCodeString = String(response.statusCode)
                completion(statusCodeString.data(using: .utf8))
                return
            }
            completion(data)
        }
        dataTask.resume()
    }
    
    
    
}
