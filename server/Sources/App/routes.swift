import Fluent
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {

    app.get { req -> EventLoopFuture<View> in
        let fileURL = app.directory.publicDirectory + "index.html"

        return req.view.render(fileURL)
    }.excludeFromOpenAPI()

    // generate OpenAPI documentation
    app.get("swagger", "swagger.json") { req in
      req.application.routes.openAPI(
        info: InfoObject(
          title: "VT1 API",
          description: "API used to export data from VT1",
          version: "0.1.0"
        )
      )
    }
    .excludeFromOpenAPI()

    app.get("status") { req in
        Status(status: "OK")
    }.openAPI(
        summary: "Get status",
        description: "Get status of the server",
        response: .type(Status.self)
    )


    try app.register(collection: DeviceController())
}
