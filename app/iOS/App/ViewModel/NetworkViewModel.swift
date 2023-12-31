//
//  Created by Julian Visser on 17.10.2023.
//

import Foundation
import UIKit

class NetworkViewModel: ObservableObject {

    let ip: String

    let uuid: String

    init(ip: String) {
        self.ip = ip
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
            fatalError("uuid not found")
        }
        self.uuid = uuid
    }

    func postDataToAPI(url: String,  data: Codable, handleSuccess: ((_ data: Codable) -> Void)?) {

        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonData = try? JSONEncoder().encode(data)
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("success", httpResponse.statusCode)
                    if let handleSuccess = handleSuccess {
                        handleSuccess(data!)
                    }
                } else {
                    print("error", httpResponse.statusCode)
                }
            }
        }.resume()
    }

    func postRecordingToAPI(_ recording: RecordingData, handleSuccess: ((_ data: Codable) -> Void)?) {
        let url = "http://" + ip + "/device/" + uuid + "/" + "recording"
        postDataToAPI(url: url, data: recording, handleSuccess: handleSuccess)
    }

    func postSensorDataToAPI(_ sensorData: SensorData, handleSuccess: ((_ data: Codable) -> Void)?) {
        let url = "http://" + ip + "/device/" + uuid + "/" + "sensorData"
        postDataToAPI(url: url, data: sensorData, handleSuccess: handleSuccess)
    }

}
