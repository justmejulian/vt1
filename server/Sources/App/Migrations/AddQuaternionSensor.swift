import Fluent

struct AddQuaternionSensor: AsyncMigration {
    func prepare(on database: Database) async throws {
        let quaternion = Sensor(
            name: "quaternion"
        )
        try await quaternion.save(on: database)
    }

    func revert(on database: Database) async throws {
        let quaternion = try await Sensor.query(on: database).filter(\.$name == "quaternion").first()
        try await quaternion?.delete(on: database)
    }
}
