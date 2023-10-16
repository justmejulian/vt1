import Fluent
import Vapor

struct DeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let devices = routes.grouped("devices")
        devices.get(use: index)
        devices.post(use: create)

        devices.group(":id") { device in
            device.get(use: show)
            device.delete(use: delete)

            device.group("data") { data in
                data.get(use: getSensorData)
                data.post(use: addSensorData)
            }
        }
    }

    func index(req: Request) async throws -> [Device] {
        // todo use uuid
        try await Device.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Device {
        let device = try req.content.decode(Device.self)
        try await device.save(on: req.db)
        // todo maybe change what is sent back
        // return .ok
        return device
    }

    func show(req: Request) async throws -> Device {
        guard let device = try await Device.find(req.parameters.get("id"), on: req.db) else {
            print("Error in show: device not found")
            throw Abort(.notFound)
        }
        return device
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let device = try await Device.find(req.parameters.get("id"), on: req.db) else {
            print("Error in delete: device not found")
            throw Abort(.notFound)
        }
        try await device.delete(on: req.db)
        return .ok
    }

    func getSensorData(req: Request) async throws -> [SensorData] {
        do {
            // todo use uuid
            let device = try await Device.find(req.parameters.get("id"), on: req.db)
            let sensorData = try await SensorData.query(on: req.db).filter(\.$device_id == (device?.id)!).all()

            // todo return names not IDs
            // ie uuid for the device and sensor name for the sensor
            return sensorData
        } catch {
            print("Error in getSensorData: \(error)")
            throw Abort(.notFound)
        }
    }

    func addSensorData(req: Request) async throws -> SensorData {
        struct AddSensorData: Content {
            var timestamp: Double
            var sensor_id: String
            var x: String
            var y: String
            var z: String
        }

        do {
            // todo use uuid
            let device = try await Device.find(req.parameters.get("id"), on: req.db)

            let addSensorData = try req.content.decode(AddSensorData.self)

            print(addSensorData)

            // todo use sensor name
            let sensor = try await Sensor.find(UUID(addSensorData.sensor_id), on: req.db)

            print(sensor)

            let sensorData = SensorData(
                id: nil,
                timestamp: Date(timeIntervalSince1970: addSensorData.timestamp),
                device_id: (device?.id)!,
                sensor_id: (sensor?.id)!,
                x: addSensorData.x,
                y: addSensorData.y,
                z: addSensorData.z
            )

            print(sensorData)

            try await sensorData.save(on: req.db)

            return sensorData
        } catch {
            print("Error in addSensorData: \(String(reflecting: error))")
            throw Abort(.notFound)
        }
    }
}
