import Fluent

struct CreateSensorData: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("sensor_data")
            .id()
            .field("timestamp", .datetime, .required)
            .field("device_id", .uuid, .required, .references("device", "id"))
            .field("sensor_id", .uuid, .required, .references("sensor", "id"))
            .field("x", .string, .required)
            .field("y", .string, .required)
            .field("z", .string, .required)
            .unique(on: "timestamp", "device_id", "sensor_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("sensor_data").delete()
    }
}
