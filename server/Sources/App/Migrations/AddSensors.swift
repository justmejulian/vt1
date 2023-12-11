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

        let gravity = Sensor(
            name: "gravity"
        )
        try await gravity.save(on: database)

        let userAcceleration = Sensor(
            name: "userAcceleration"
        )
        try await userAcceleration.save(on: database)
    }

    func revert(on database: Database) async throws {
        let acceleration = try await Sensor.query(on: database).filter(\.$name == "acceleration").first()
        try await acceleration?.delete(on: database)

        let rotationRate = try await Sensor.query(on: database).filter(\.$name == "rotationRate").first()
        try await rotationRate?.delete(on: database)

        let gravity = try await Sensor.query(on: database).filter(\.$name == "gravity").first()
        try await gravity?.delete(on: database)

        let userAcceleration = try await Sensor.query(on: database).filter(\.$name == "userAcceleration").first()
        try await userAcceleration?.delete(on: database)
    }
}
