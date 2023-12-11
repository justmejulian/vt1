import Fluent

struct AddSensors: AsyncMigration {
    func prepare(on database: Database) async throws {
        let acceleration = Sensor(
            name: "acceleration"
        )
        try await acceleration.save(on: database)
        let rotationRate = Sensor(
            name: "rotationRate"
        )
        try await rotationRate.save(on: database)
    }

    func revert(on database: Database) async throws {
        let acceleration = try await Sensor.query(on: database).filter(\.$name == "acceleration").first()
        let rotationRate = try await Sensor.query(on: database).filter(\.$name == "rotationRate").first()
        try await acceleration?.delete(on: database)
        try await rotationRate?.delete(on: database)
    }
}
