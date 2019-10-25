import Routing
import Vapor
import Foundation

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    
    router.get("Check") { req -> String in
        let loadData = LoadDataProvider()
        loadData.checkConnection(req: req)
        return "Check Started"
    }
    
    router.get("Load") { req -> String in
        let loadData = LoadDataProvider()
        loadData.loadDeptDataFromWeb(req: req)
        return "Load Started..."
    }
    
    router.get("LoadPhotos") { req -> String in
        let loadData = LoadDataProvider()
        var i = 0
        let _ = Sotrud.query(on: req).all().map { results in
            let sotruds = results
            loadData.loadPhoto(sotruds: sotruds, i: &i, req: req)
        }
        return "Load Photos Started..."
    }
    
    router.get("ZipPhotos") { req -> String in
        let loadData = LoadDataProvider()
        var i = 0
        let _ = Sotrud.query(on: req).all().map { results in
            let sotruds = results
            loadData.loadPhoto(sotruds: sotruds, i: &i, req: req)
        }
        return "Zip Photos Started..."
    }
    
    router.get("Genders") { req -> Future<[Gender]> in
        return Gender.query(on: req).all()
    }
    
    router.get("StaffTypes") { req -> Future<[StaffType]> in
        return StaffType.query(on: req).all()
    }
    
    router.get("Staffs") { req -> Future<[Staff]> in
        return Staff.query(on: req).all()
    }
    
    router.get("Depts") { req -> Future<[Dept]> in
        return Dept.query(on: req).all()
    }
    
    router.get("Sotruds") { req -> Future<[Sotrud]> in
        return Sotrud.query(on: req).all()
    }
    
    router.get("Sotrud", String.parameter) { req -> Future<[Sotrud]> in
        let kod = try req.parameters.next(String.self)
        let query = Sotrud.query(on: req).filter(\Sotrud.kod, ._equal, kod).all()
        return query
    }
    
    
    
}
