import Fluent
import PostgresNIO
import Vapor

struct DeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let devices = routes.grouped("devices")
        devices.get(use: index)
        devices.post(use: create)

        devices.group(":id") { device in
            device.get(use: show)
            device.delete(use: delete)

            device.group("sensorData") { data in
                data.post(use: addSensorData)
            }
            device.group("recording") { data in
                data.post(use: addRecordingData)
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
            throw Abort(.internalServerError)
        }
        return device
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let device = try await Device.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await device.delete(on: req.db)
        return .ok
    }

//    func getSensorData(req: Request) async throws -> [SensorData] {
//        do {
//            // todo use uuid
//            guard let deviceId = req.parameters.get("id") else {
//                print("Error, deviceId not provided")
//                throw Abort(.badRequest)
//            }
//
//            guard let device: Device = try? await Device.find(UUID(deviceId), on: req.db) else {
//                print("Error, device not found")
//                throw Abort(.notFound)
//            }
//
//            // let sensorData = try await SensorData.query(on: req.db).filter(\.$device_id == device.id!).all()
//
//            // todo return names not IDs
//            // ie uuid for the device and sensor name for the sensor
//            return sensorData
//        } catch {
//            print("Error in getSensorData: \(error)")
//            throw Abort(.internalServerError)
//        }
//    }

    struct Values: Content {
        var x: Double
        var y: Double
        var z: Double
        var timestamp: Double
    }
    struct AddSensorData: Content {
        var recordingStart: Double
        var sensor_id: String
        var timestamp: Double
        var values: [Values]
    }

    func addSensorData(req: Request) async throws -> HTTPStatus {
        print("addSensorData")
        print(req)
        do {
            let addSensorData = try req.content.decode(AddSensorData.self)

            // todo use sensor name
            guard let sensor = try await Sensor.query(on: req.db).filter(\.$name == addSensorData.sensor_id).first() else {
                print("Error, sensor not found", addSensorData.sensor_id)
                throw Abort(.notFound)
            }

            for value in addSensorData.values {
                let sensorData = SensorData(
                    id: nil,
                    recording_start: Date(timeIntervalSince1970: addSensorData.recordingStart),
                    sensor_id: sensor.id!,
                    timestamp: Date(timeIntervalSince1970: value.timestamp),
                    x: value.x,
                    y: value.y,
                    z: value.z
                )
                try await sensorData.save(on: req.db)
            }

            return .ok

        } catch {
            if (((error as? PSQLError)?.isConstraintFailure) != nil) {
                print("Already exists in addSensorData: \(String(reflecting: error))")
                return .ok
            }
            
            print("Error in addSensorData: \(String(reflecting: error))")
            throw Abort(.notFound)
        }
    }

    struct AddRecordingData: Content {
        var startTimestamp: Double
        var exercise: String
    }

    func getDevice(req: Request) async throws -> Device {
        do {
            guard let deviceId: String = req.parameters.get("id") else {
                print("Error, deviceId not provided")
                throw Abort(.badRequest)
            }

            if let device: Device = try await Device.query(on: req.db).filter(\.$uuid == deviceId).first() {
                return device
            }

            let device: Device = Device(id: nil, uuid: deviceId)
            try await device.save(on: req.db)
            return device
        } catch {
            print("Error in getDevice: \(String(reflecting: error))")
            throw Abort(.notFound)
        }
    }

    func addRecordingData(req: Request) async throws -> HTTPStatus {
        print("addRecordingData")
        print(req)
        do {
            let device = try await getDevice(req: req)
            guard let device_id = device.id else {
                print("Error, device id not found")
                throw Abort(.notFound)
            }

            let addRecordingData = try req.content.decode(AddRecordingData.self)

            let recordingData = RecordingData(
                id: nil,
                device_id: device_id,
                start_time: Date(timeIntervalSince1970: addRecordingData.startTimestamp),
                exercise: addRecordingData.exercise
            )

            try await recordingData.save(on: req.db)
        } catch {
            if (((error as? PSQLError)?.isConstraintFailure) != nil) {
                print("Already exists in addRecordingData: \(String(reflecting: error))")
                return .ok
            }
            
            print("Error in addRecordingData: \(String(reflecting: error))")
            throw Abort(.notFound)
        }
        
        return .ok
    }
}
