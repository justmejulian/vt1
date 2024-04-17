//  vt1 Mobile App
//
//  Created by Julian Visser on 17.04.2024.
//

import Foundation

import SwiftData

@Model
class SyncData: Codable {

    enum CodingKeys: CodingKey {
        case ip
    }

    var ip: String

    init(ip: String) {
        self.ip = ip
    }

    // -- Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ip = try container.decode(String.self, forKey: .ip)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ip, forKey: .ip)
    }
}
