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
    
    
}
