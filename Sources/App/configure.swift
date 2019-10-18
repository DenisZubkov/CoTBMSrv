import Vapor
import FluentMySQL
import Fluent
import Foundation

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    try services.register(FluentMySQLProvider())
    
    let mysqlConfig = MySQLDatabaseConfig(hostname: "dcluster-node-2.tbm.ru", port: 3306, username: "root", password: "fox", database: "cotbm", capabilities: .default, characterSet: .utf8_general_ci, transport: .unverifiedTLS)
    let mysql = MySQLDatabase(config: mysqlConfig)
    
    var databaseConfig = DatabasesConfig()
    databaseConfig.add(database: mysql, as: .mysql)
    services.register(databaseConfig)
    
    var migrationConfig = MigrationConfig()

    migrationConfig.add(model: Gender.self, database: .mysql)
    migrationConfig.add(model: StaffType.self, database: .mysql)
    migrationConfig.add(model: Staff.self, database: .mysql)
    migrationConfig.add(model: Dept.self, database: .mysql)
    migrationConfig.add(model: Sotrud.self, database: .mysql)
    migrationConfig.add(model: LoadLog.self, database: .mysql)
    services.register(migrationConfig)
    
}
