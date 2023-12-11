import Fluent

struct CreateSensorData: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("sensor_data")
            .id()
            .field("recording_start", .datetime)
            .field("sensor_id", .uuid)
            .field("timestamp", .datetime)
            .field("x", .double)
            .field("y", .double)
            .field("z", .double)
            .unique(on: "recording_start", "sensor_id", "timestamp")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("sensor_data").delete()
    }
}
