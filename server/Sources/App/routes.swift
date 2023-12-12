import Fluent
import Vapor

func routes(_ app: Application) throws {

    // todo maybe remove and send in chunks
    app.routes.defaultMaxBodySize = "100mb"

    app.get { req async -> String in
        "VT1 - Julian Visser"
    }

    app.get("status") { req in
        Status(status: "OK")
    }

    try app.register(collection: DeviceController())
}
