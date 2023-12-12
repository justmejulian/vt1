import Fluent
import PostgresNIO
import Vapor

struct DeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let _ = routes.group("devices") { route in
            route.get(use: index)
        }
        
        
        let _ = routes.group("device") { route in
            route.post(use: create)
            
            let _ = route.group(":id") { device in
                
                device.post(use: create)
                
                device.get(use: show)
                device.delete(use: delete)

                device.group("sensorData") { data in
                    data.post(use: addSensorData)
                }

                device.group("recording") { data in
                    data.post(use: addRecordingData)
                    data.get(use: getRecordings)
                }
            }
        }


        
        let _ = routes.group("recording") { route in
            route.group(":recordingId") { recording in
                recording.get(use: getSensorDataForRecording)
            }
        }
    }
    
    func getDevice(req: Request) async throws -> Device {
        do {
            guard let deviceId: String = req.parameters.get("id") else {
                print("Error, deviceId not provided")
                throw Abort(.badRequest)
            }

            return try await Device.query(on: req.db).filter(\.$uuid == deviceId).first()!
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
        var sensorData: Int
    }
    
    func show(req: Request) async throws -> ShowDevice {
        let device = try await getDevice(req: req)
        
        guard let device_id = device.id else {
            print("Error, device id not found")
            throw Abort(.notFound)
        }
                
        var recordingsCount = 0
        var sensorDataCount = 0
        do {
            let recordings = try await RecordingData.query(on: req.db).filter(\.$device_id == device.id!).all()
            recordingsCount = recordings.count
            
            for recording in recordings {
                let sensorData = try await SensorData.query(on: req.db).filter(\.$recording_start == recording.start_time).all()
                sensorDataCount += sensorData.count
            }
        }

        return ShowDevice(id: device_id , uuid: device.uuid, recordings: recordingsCount, sensorData: sensorDataCount)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let device = try await getDevice(req: req)
        try await device.delete(on: req.db)
        return .ok
    }

    func getRecordings(req: Request) async throws -> [RecordingData] {
        do {
            let device = try await getDevice(req: req)

            let recordings = try await RecordingData.query(on: req.db).filter(\.$device_id == device.id!).all()

            return recordings
        } catch {
            print("Error in getRecordings: \(error)")
            throw Abort(.internalServerError)
        }
    }

    func getSensorDataForRecording(req: Request) async throws -> [SensorData] {
        do {
            guard let recordingId = req.parameters.get("recordingId") else {
                print("Error, recordingId not provided")
                throw Abort(.badRequest)
            }

            guard let recording: RecordingData = try? await RecordingData.find(UUID(recordingId), on: req.db) else {
                print("Error, recording not found")
                throw Abort(.notFound)
            }

            let sensorData = try await SensorData.query(on: req.db).filter(\.$recording_start == recording.start_time).all()

            return sensorData
        } catch {
            print("Error in getSensorDataForRecording: \(error)")
            throw Abort(.internalServerError)
        }
    }

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

    func addRecordingData(req: Request) async throws -> HTTPStatus {
        print("addRecordingData")
        print(req)
        do {
            let device = try await getDeviceOrAddDevice(req: req)
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
