//
//  Created by Julian Visser on 12.11.2023.
//

import Foundation

@Observable
class RecordingListViewModel {
        @ObservationIgnored
        private let dataSource: DataSource

        var recordings: [RecordingData]

        init(dataSource: DataSource = DataSource.shared) {
            self.dataSource = dataSource
            recordings = dataSource.fetchRecordingArray()
            print(recordings)
        }
}
