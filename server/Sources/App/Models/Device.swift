import Fluent
import Vapor

final class Device: Model, Content {
    static let schema = "device"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "uuid")
    var uuid: String

    init() { }

    init(id: UUID? = nil, uuid: String) {
        self.id = id
        self.uuid = uuid
    }
}
