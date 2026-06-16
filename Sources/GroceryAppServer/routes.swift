import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Local server works!"
    }

    app.get("hello") { req async -> String in
        "Hello, Vapor!"
    }
    
    try app.register(collection: UserController())
    try app.register(collection: GroceryController())
}
