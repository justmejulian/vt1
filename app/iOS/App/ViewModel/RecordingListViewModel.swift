//
//  Created by Julian Visser on 12.11.2023.
//

import Foundation
import OSLog

@Observable
class RecordingListViewModel {
        @ObservationIgnored
        private let dataSource: DataSource

        var recordings: [RecordingData]

        init(dataSource: DataSource = DataSource.shared) {
            self.dataSource = dataSource
            recordings = dataSource.fetchRecordingArray()
            Logger.statistics.debug("Count of recordings \(self.recordings.count)")
        }
}
