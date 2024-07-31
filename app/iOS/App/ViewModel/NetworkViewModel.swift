//
//  Created by Julian Visser on 17.10.2023.
//

import Foundation
import UIKit
import OSLog


// todo move to @Observable and move to Manager
// https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro
@MainActor
class NetworkViewModel: ObservableObject {
    
    let compressionManager = CompressionManager()

    let ip: String

    let uuid: String
    
    init(ip: String) {
        self.ip = ip
        
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
            Logger.viewCycle.error("uuid not found")
            fatalError("uuid not found")
        }
        
        self.uuid = uuid
    }
    
    func getStatus() async -> Bool{
        
        let urlString = "http://" + ip + "/status"
        guard let url = URL(string: urlString) else {
            Logger.viewCycle.error("Invalid URL in getStatus \(urlString)")
            return false
        }

        // todo send the compressed data
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            Logger.viewCycle.debug("Server reacable: \(response)")
            return true
        } catch {
            Logger.viewCycle.error("Error getStatus \(error)")
            return false
        }

    }
    
    // todo do this on a different Thread
    func postDataToAPI(url: String,  data: Data, handleSuccess: (@Sendable (_ data: Codable) -> Void)?) {

        guard let url = URL(string: url) else {
            Logger.viewCycle.error("Invalid URL in postDataToAPI \(url)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = data

        // todo send the compressed data
        // https://www.wwdcnotes.com/notes/wwdc21/10095/
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                Logger.viewCycle.error("\(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    Logger.viewCycle.debug("success postDataToAPI \(httpResponse.statusCode)")
                    if let handleSuccess = handleSuccess {
                        handleSuccess(data!)
                    }
                } else {
                    Logger.viewCycle.error("error postDataToAPI \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

    func postCodableDataToAPI(url: String,  data: Codable, handleSuccess: (@Sendable (_ data: Codable) -> Void)?) {
        guard let jsonData = try? JSONEncoder().encode(data) else {
            Logger.viewCycle.error("Failed to convert to Json")
            return
        }
        postDataToAPI(url: url, data: jsonData, handleSuccess: handleSuccess)
    }

    func postRecordingToAPI(_ recording: RecordingStruct, handleSuccess: (@Sendable (_ data: Codable) -> Void)?) {
        
        // todo move these urls out so that they are only built 1
        let url = "http://" + ip + "/device/" + uuid + "/" + "recording"
        Logger.viewCycle.debug("postRecordingToAPI :\(url)")
        postCodableDataToAPI(url: url, data: recording, handleSuccess: handleSuccess)
    }

    func postSensorBatchToAPI(_ sensorBatch: SensorBatchStruct, handleSuccess: (@Sendable (_ data: Codable) -> Void)?) {
        let url = "http://" + ip + "/device/" + uuid + "/" + "sensorBatch"
        Logger.viewCycle.debug("postSensorBatchToAPI :\(url)")
        postCodableDataToAPI(url: url, data: sensorBatch, handleSuccess: handleSuccess)
    }
    
    func postSensorBatchArrayToAPI(_ sensorBatchArray: [SensorBatchStruct], handleSuccess: (@Sendable (_ data: Codable) -> Void)?) {
        let url = "http://" + ip + "/device/" + uuid + "/" + "sensorBatch/batch"
        Logger.viewCycle.debug("postSensorBatchToAPI :\(url)")

        guard let jsonData = try? JSONEncoder().encode(sensorBatchArray) else {
            Logger.viewCycle.error("Failed to convert to Json")
            return
        }

        guard let compressedJsonData = try? compressionManager.compressData(jsonData) else {
            Logger.viewCycle.error("Failed to compress to sensorBatchArray")
            return
        }

        guard let compressedJsonDataEncoded = try? JSONEncoder().encode(compressedJsonData as Data) else {
            Logger.viewCycle.error("Failed to convert compressedJsonData to Json")
            return
        }

        postDataToAPI(url: url, data: compressedJsonDataEncoded, handleSuccess: handleSuccess)
    }

}
