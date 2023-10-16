import Fluent

struct CreateSensor: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("sensor")
            .id()
            .field("name", .string, .required)
            .unique(on: "name")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("sensor").delete()
    }
}
