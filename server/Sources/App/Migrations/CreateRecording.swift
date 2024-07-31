import Fluent

struct CreateRecording: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("recording_data")
            .id()
            .field("device_id", .uuid)
            .field("start_time", .datetime)
            .field("exercise", .string)
            .unique(on: "device_id", "start_time")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("sensor_data").delete()
    }
}
