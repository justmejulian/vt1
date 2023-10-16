import Fluent

struct AddSensors: AsyncMigration {
    func prepare(on database: Database) async throws {
        let accelerometer = Sensor(
            name: "Accelerometer"
        )
        try await accelerometer.save(on: database)
        let gyroscope = Sensor(
            name: "Gyroscope"
        )
        try await gyroscope.save(on: database)
    }

    func revert(on database: Database) async throws {
        let accelerometer = try await Sensor.query(on: database).filter(\.$name == "Accelerometer").first()
        let gyroscope = try await Sensor.query(on: database).filter(\.$name == "Gyroscope").first()
        try await accelerometer?.delete(on: database)
        try await gyroscope?.delete(on: database)
    }
}
