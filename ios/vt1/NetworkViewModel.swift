//
//  NetworkViewModel.swift
//  vt1
//
//  Created by Julian Visser on 17.10.2023.
//

import Foundation

class NetworkViewModel: ObservableObject {
    // todo remove any
    func postDataToAPI(data: [String: Any], completion: @escaping (Error?) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8080/devices/30D1E9CF-4773-4EA6-8DCE-D9B16ADB47C6/data") else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
