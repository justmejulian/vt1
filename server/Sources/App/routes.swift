import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        Status(status: "OK")
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: TodoController())
}
