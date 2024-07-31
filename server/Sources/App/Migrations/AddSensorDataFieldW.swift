import Fluent

struct AddSensorBatchFieldW: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("sensor_data")
            .field("w", .double)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("sensor_data")
            .deleteField("w")
            .update()
    }
}
