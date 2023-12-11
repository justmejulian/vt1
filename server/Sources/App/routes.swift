import Fluent
import Vapor

func routes(_ app: Application) throws {

    // todo maybe remove and send in chunks
    app.routes.defaultMaxBodySize = "100mb"

    app.get { req async -> String in
        "Todo add list of routes"
    }

    app.get("status") { req in
        Status(status: "OK")
    }

    try app.register(collection: DeviceController())
}
