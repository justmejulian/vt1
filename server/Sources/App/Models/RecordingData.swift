import Fluent
import Vapor

final class RecordingData: Model, Content {
    static let schema = "recording_data"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "device_id")
    var device_id: UUID

    @Field(key: "start_time")
    var start_time: Date

    @Field(key: "exercise")
    var exercise: String

    init() { }

    init(id: UUID? = UUID(), device_id: UUID, start_time: Date, exercise: String) {
        self.id = id
        self.device_id = device_id
        self.start_time = start_time
        self.exercise = exercise
    }
}
