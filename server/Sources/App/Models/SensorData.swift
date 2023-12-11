import Fluent
import Vapor

final class SensorData: Model, Content {
    static let schema = "sensor_data"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "recording_start")
    var recording_start: Date

    @Field(key: "sensor_id")
    var sensor_id: UUID

    @Field(key: "timestamp")
    var timestamp: Date

    @Field(key: "x")
    var x: Double

    @Field(key: "y")
    var y: Double

    @Field(key: "z")
    var z: Double

    init() { }

    init(id: UUID? = UUID(), recording_start: Date, sensor_id: UUID, timestamp: Date, x: Double, y: Double, z: Double) {
        self.id = id
        self.recording_start = recording_start
        self.sensor_id = sensor_id
        self.timestamp = timestamp
        self.x = x
        self.y = y
        self.z = z
    }
}
