//
//  Created by Julian Visser on 17.10.2023.
//

import Foundation

class NetworkViewModel: ObservableObject {
    // todo remove any
    func postDataToAPI(_ data: Codable) {
        // todo device name
        //guard let url = URL(string: "http://192.168.1.251:8080/devices/30D1E9CF-4773-4EA6-8DCE-D9B16ADB47C6/data") else {
        guard let url = URL(string: "http://192.168.1.251:8080/device") else {
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
            }
        }.resume()
    }
}
