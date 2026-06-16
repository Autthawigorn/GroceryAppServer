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
    app.migrations.add(CreateGroceryItemTableMigration())
    // try await app.autoMigrate()
    
    // Environment.get("JWT_SECRET") อ่านค่าจาก environment variable ของ server
    // - Local dev: ยังไม่ได้ตั้ง → ใช้ค่า fallback ?? ไปก่อน
    // - Production (Railway / Heroku / Docker): ต้องไปตั้ง JWT_SECRET ใน dashboard ของ platform นั้น
    //   แล้ว Environment.get() จะดึงค่านั้นมาใช้แทน fallback อัตโนมัติ
    //   ค่า secret ควรเป็น random string ยาวๆ เช่น UUID หรือ openssl rand -hex 32
    let jwtSecret = Environment.get("JWT_SECRET") ?? "local-dev-secret-change-in-production"
    await app.jwt.keys.add(hmac: HMACKey(stringLiteral: jwtSecret), digestAlgorithm: .sha256)

    try routes(app)
}
