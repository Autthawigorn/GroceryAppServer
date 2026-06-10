import Vapor
import Fluent
import FluentPostgresDriver
import JWT
import JWTKit

public func configure(_ app: Application) async throws {
    if let databaseURL = Environment.get("DATABASE_URL") {
        try app.databases.use(.postgres(url: databaseURL), as: .psql)
    } else {
        app.databases.use(.postgres(configuration: .init(
            hostname: "localhost",
            username: "postgres",
            password: "",
            database: "grocerydb",
            tls: .disable
        )), as: .psql)
    }

    // register migration
    app.migrations.add(CreateUserTableMigration())
    app.migrations.add(CreateGroceryCategoryTableMigration())
    // try await app.autoMigrate()
    
    // register the controller
    try app.register(collection: UserController())
    try app.register(collection: GroceryController())
    
    await app.jwt.keys.add(hmac: "SECRET-KEY", digestAlgorithm: .sha256)
    
    try routes(app)
}
