//
//  Created by Julian Visser on 12.11.2023.
//

import Foundation
import OSLog

@Observable
class RecordingListViewModel {
    private let db: Database
    
    init(db: Database) {
        self.db = db
    }
    
    func deleteAll(){
        Logger.viewCycle.info("Calling dataSource.clear from RecordingListViewModel")
        // todo add clear here
    }
}
