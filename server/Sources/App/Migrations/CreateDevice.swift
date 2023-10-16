import Fluent

struct CreateDevice: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("device")
            .id()
            .field("uuid", .string, .required)
            .unique(on: "uuid")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("device").delete()
    }
}
