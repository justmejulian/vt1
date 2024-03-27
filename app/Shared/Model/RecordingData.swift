//
//  vt1
//
//  Created by Julian Visser on 25.10.2023.
//

import Foundation
import SwiftData

@Model
class RecordingData: Codable{

    enum CodingKeys: CodingKey {
        case exercise
        case startTimestamp
    }

    var exercise: String
    let startTimestamp: Date

    init(exercise: String = "Default", startTimestamp: Date, isSynced: Bool = false) {
        self.exercise = exercise
        self.startTimestamp = startTimestamp
    }

    // -- Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.exercise = try container.decode(String.self, forKey: .exercise)
        self.startTimestamp = try container.decode(Date.self, forKey: .startTimestamp)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(exercise, forKey: .exercise)
        try container.encode(startTimestamp, forKey: .startTimestamp)
    }
}
