import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    
    // use ms for dates
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
    jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
    ContentConfiguration.global.use(encoder: jsonEncoder, for: .json)
    ContentConfiguration.global.use(decoder: jsonDecoder, for: .json)
    
    // todo maybe remove and send in chunks
    app.routes.defaultMaxBodySize = "100mb"
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateDevice())
    app.migrations.add(CreateSensor())
    app.migrations.add(CreateSensorData())
    app.migrations.add(CreateRecordingData())
    app.migrations.add(AddSensors())
    app.migrations.add(AddQuaternionSensor())

    // run migrations
    try await app.autoMigrate()

    // register routes
    try routes(app)
}
