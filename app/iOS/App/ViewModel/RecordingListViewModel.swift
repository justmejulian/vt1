//
//  Created by Julian Visser on 12.11.2023.
//

import Foundation
import OSLog

@Observable
class RecordingListViewModel {
        @ObservationIgnored
        private let dataSource: DataSource

        init(dataSource: DataSource) {
            self.dataSource = dataSource
        }
    
    func deleteAll(){
        Logger.viewCycle.info("Calling dataSource.clear from RecordingListViewModel")
        dataSource.clear()
    }
}
