import Fluent
import Vapor

final class SensorData: Model, Content {
    static let schema = "sensor_data"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "timestamp")
    var timestamp: Date

    @Field(key: "device_id")
    var device_id: UUID

    @Field(key: "sensor_id")
    var sensor_id: UUID

    @Field(key: "x")
    var x: Double

    @Field(key: "y")
    var y: Double

    @Field(key: "z")
    var z: Double

    init() { }

    init(id: UUID? = nil, timestamp: Date, device_id: UUID, sensor_id: UUID, x: Double, y: Double, z: Double) {
        self.id = id
        self.timestamp = timestamp
        self.device_id = device_id
        self.sensor_id = sensor_id
        self.x = x
        self.y = y
        self.z = z
    }

}
