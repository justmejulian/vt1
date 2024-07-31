import Fluent
import PostgresNIO
import Vapor

struct DeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {

        let _ = routes.group("sensors") { route in
            route.get(use: getSensors).openAPI(
                summary: "Get all sensors",
                description: "Get all sensors",
                response: .type([Sensor].self)
            )
        }
        
        let _ = routes.group("devices") { route in
            route.get(use: index).openAPI(
                summary: "Get all devices",
                description: "Get all devices",
                response: .type([Device].self)
            )
        }
        
        
        let _ = routes.group("device") { route in
            route.post(use: create).openAPI(
                summary: "Create a device",
                description: "Create a device",
                response: .type(Device.self)
            )
            
            let _ = route.group(":id") { device in
                
                device.post(use: create).openAPI(
                    summary: "Create a device",
                    description: "Create a device",
                    response: .type(Device.self)
                )
                
                device.get(use: show).openAPI(
                    summary: "Get a device",
                    description: "Get a device",
                    response: .type(ShowDevice.self)
                )
                device.delete(use: delete).openAPI(
                    summary: "Delete a device",
                    description: "Delete a device",
                    response: .type(HTTPStatus.self)
                )

                device.group("sensorBatch") { data in
                    data.post(use: addSensorBatch).openAPI(
                        summary: "Add sensor data",
                        description: "Add sensor data",
                        response: .type(HTTPStatus.self)
                    )
                    data.group("batch") { batch in
                        batch.post(use: addSensorBatchArray).openAPI(
                            summary: "Add sensor data Array",
                            description: "Add sensor data Array",
                            response: .type(HTTPStatus.self)
                        )
                    }
                }

                device.group("recording") { data in
                    data.post(use: addRecording).openAPI(
                        summary: "Add recording data",
                        description: "Add recording data",
                        response: .type(HTTPStatus.self)
                    )
                }
                device.group("recordings") { data in
                    data.get(use: getRecordings).openAPI(
                        summary: "Get recordings",
                        description: "Get recordings",
                        response: .type([Recording].self)
                    )
                }
            }
        }


        
        let _ = routes.group("recording") { route in
            route.group(":recordingId") { recording in
                recording.get(use: getSensorBatchForRecording).openAPI(
                    summary: "Get sensor data for recording",
                    description: "Get sensor data for recording",
                    response: .type([SensorBatch].self)
                )
            }
        }
    }
    
    func getDevice(req: Request) async throws -> Device {
        do {
            guard let deviceId: String = req.parameters.get("id") else {
                print("Error, deviceId not provided")
                throw Abort(.badRequest)
            }

            guard let device = try await Device.query(on: req.db).filter(\.$uuid == deviceId).first() else {
                print("Error, device not found")
                throw Abort(.notFound)
            }
            return device

        } catch {
            print("Error in getDevice: \(String(reflecting: error))")
            throw Abort(.notFound)
        }
    }

    func getDeviceOrAddDevice(req: Request) async throws -> Device {
        do {
            guard let deviceId: String = req.parameters.get("id") else {
                print("Error, deviceId not provided")
                throw Abort(.badRequest)
            }
            
            do {
                let device: Device = try await getDevice(req: req)
                
                return device
            } catch {
                print("Could not find Device for", deviceId)
                print("Adding new Device for", deviceId)

                let device: Device = Device(id: nil, uuid: deviceId)
                try await device.save(on: req.db)
                return device
            }

        } catch {
            print("Error in getDevice: \(String(reflecting: error))")
            throw Abort(.notFound)
        }
    }

    func getSensors(req: Request) async throws -> [Sensor] {
        do {
            let sensors = try await Sensor.query(on: req.db).all()
            return sensors
        } catch {
            print("Error in getSensors: \(error)")
            throw Abort(.internalServerError)
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

    
    struct ShowDevice: Content {
        var id: UUID
        var uuid: String
        var recordings: Int
        var sensorBatch: Int
    }
    
    func show(req: Request) async throws -> ShowDevice {
        let device = try await getDevice(req: req)
        
        guard let device_id = device.id else {
            print("Error, device id not found")
            throw Abort(.notFound)
        }
                
        var recordingsCount = 0
        var sensorBatchCount = 0
        do {
            let recordings = try await Recording.query(on: req.db).filter(\.$device_id == device.id!).all()
            recordingsCount = recordings.count
            
            for recording in recordings {
                let sensorBatch = try await SensorBatch.query(on: req.db).filter(\.$recording_start == recording.start_time).all()
                sensorBatchCount += sensorBatch.count
            }
        }

        return ShowDevice(id: device_id , uuid: device.uuid, recordings: recordingsCount, sensorBatch: sensorBatchCount)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let device = try await getDevice(req: req)
        try await device.delete(on: req.db)
        return .ok
    }

    func getRecordings(req: Request) async throws -> [Recording] {
        do {
            let device = try await getDevice(req: req)

            let recordings = try await Recording.query(on: req.db).filter(\.$device_id == device.id!).all()

            return recordings
        } catch {
            print("Error in getRecordings: \(error)")
            throw Abort(.internalServerError)
        }
    }

    func getSensorBatchForRecording(req: Request) async throws -> [SensorBatch] {
        do {
            guard let recordingId = req.parameters.get("recordingId") else {
                print("Error, recordingId not provided")
                throw Abort(.badRequest)
            }

            guard let recording: Recording = try? await Recording.find(UUID(recordingId), on: req.db) else {
                print("Error, recording not found")
                throw Abort(.notFound)
            }

            // todo lean out return data
            let sensorBatch = try await SensorBatch.query(on: req.db).filter(\.$recording_start == recording.start_time).filter(\.$device_id == recording.device_id).all()

            return sensorBatch
        } catch {
            print("Error in getSensorBatchForRecording: \(error)")
            throw Abort(.internalServerError)
        }
    }

    struct Values: Content {
        var x: Double
        var y: Double
        var z: Double
        var w: Double?
        var timestamp: Double
    }
    struct AddSensorBatch: Content {
        var recordingStart: Double
        var sensor_id: String
        var timestamp: Double
        var values: [Values]
    }
    
    func addSensorBatchArray(req: Request) async throws -> HTTPStatus {
        print("Calling addSensorBatchArray")
        do {
            let compressedData = try req.content.decode(Data.self)
            print(compressedData)
            let decompressedData = try (compressedData as NSData).decompressed(using: .lzma)
            print(decompressedData)

            guard let addSensorBatchArray = try? JSONDecoder().decode([AddSensorBatch].self, from: decompressedData as Data) else {
                print("Failed to decode addSensorBatchArray")
                throw Abort(.notFound)
            }

            let device = try await getDeviceOrAddDevice(req: req)

            // todo use sensor name
            var sensorBatchArray: [SensorBatch] = []
            for addSensorBatch in addSensorBatchArray {
                
                guard let sensor = try await Sensor.query(on: req.db).filter(\.$name == addSensorBatch.sensor_id).first() else {
                    print("Error, sensor not found", addSensorBatch.sensor_id)
                    throw Abort(.notFound)
                }
                sensorBatchArray = addSensorBatch.values.map({
                    value in
                    return SensorBatch(
                        id: nil,
                        recording_start: Date(timeIntervalSinceReferenceDate: addSensorBatch.recordingStart),
                        device_id: device.id!,
                        sensor_id: sensor.id!,
                        timestamp: Date(timeIntervalSinceReferenceDate: value.timestamp),
                        x: value.x,
                        y: value.y,
                        z: value.z,
                        w: value.w
                    )
                })
            }

            try await sensorBatchArray.create(on: req.db)
            return .ok
        } catch {
            if (((error as? PSQLError)?.isConstraintFailure) != nil) {
                print("Already exists in addSensorBatch: \(String(reflecting: error))")
                return .ok
            }
            
            print("Error in addSensorBatchArray: \(String(reflecting: error))")
            throw Abort(.notFound)
        }
    }

    func addSensorBatch(req: Request) async throws -> HTTPStatus {
        do {
            let addSensorBatch = try req.content.decode(AddSensorBatch.self)

            let device = try await getDeviceOrAddDevice(req: req)

            // todo use sensor name
            guard let sensor = try await Sensor.query(on: req.db).filter(\.$name == addSensorBatch.sensor_id).first() else {
                print("Error, sensor not found", addSensorBatch.sensor_id)
                throw Abort(.notFound)
            }

            for value in addSensorBatch.values {
                let sensorBatch = SensorBatch(
                    id: nil,
                    recording_start: Date(timeIntervalSinceReferenceDate: addSensorBatch.recordingStart),
                    device_id: device.id!,
                    sensor_id: sensor.id!,
                    timestamp: Date(timeIntervalSinceReferenceDate: value.timestamp),
                    x: value.x,
                    y: value.y,
                    z: value.z,
                    w: value.w
                )
                try await sensorBatch.save(on: req.db)
            }

            return .ok

        } catch {
            if (((error as? PSQLError)?.isConstraintFailure) != nil) {
                print("Already exists in addSensorBatch: \(String(reflecting: error))")
                return .ok
            }
            
            print("Error in addSensorBatch: \(String(reflecting: error))")
            throw Abort(.notFound)
        }
    }

    struct AddRecording: Content {
        var startTimestamp: Double
        var exercise: String
    }

    func addRecording(req: Request) async throws -> HTTPStatus {
        do {
            let device = try await getDeviceOrAddDevice(req: req)
            guard let device_id = device.id else {
                print("Error, device id not found")
                throw Abort(.notFound)
            }

            let addRecording = try req.content.decode(AddRecording.self)

            let recording = Recording(
                id: nil,
                device_id: device_id,
                start_time: Date(timeIntervalSinceReferenceDate: addRecording.startTimestamp),
                exercise: addRecording.exercise
            )

            try await recording.save(on: req.db)
        } catch {
            if (((error as? PSQLError)?.isConstraintFailure) != nil) {
                print("Already exists in addRecording: \(String(reflecting: error))")
                return .ok
            }
            
            print("Error in addRecording: \(String(reflecting: error))")
            throw Abort(.notFound)
        }
        
        return .ok
    }
}
