//
//  CompressedDataListViewModel.swift
//  vt1 Mobile App
//
//  Created by Julian Visser on 27.04.2024.
//

import Foundation
import OSLog

class CompressedDataListViewModel: ObservableObject{
    
    @ObservationIgnored
    let dataSource: DataSource
    
    let compressionManager = CompressionManager()
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    func clearAll() {
        Logger.viewCycle.info("Calling dataSource.clear from CompressedDataListViewModel")
        dataSource.clear(dataModel: CompressedData.self)
    }
    
    func compressData() {
        let recordingArray = dataSource.fetchRecordingArray()
        
        recordingArray.forEach({ recording in
            do {
                let sensorData = dataSource.fetchSensorDataArray(timestamp: recording.startTimestamp)
                let dict: RecordingDictionary = RecordingDictionary(
                    exercise: recording.exercise,
                    startTimestamp: recording.startTimestamp.timeIntervalSince1970,
                    data: sensorData
                )

                let jsonData = try JSONEncoder().encode(dict)
                let compressedFile = try compressionManager.compressData(jsonData)
                
                let fileName = recording.exercise
                let compressedData = CompressedData(fileName: fileName, file: compressedFile)
                dataSource.appendCompressedData(compressedData)
            } catch {
                Logger.viewCycle.error("Error compressing \(error.localizedDescription)")
            }
        })
    
    }
}

struct RecordingDictionary: Encodable {
    var exercise: String
    var startTimestamp: TimeInterval
    var data: [SensorData]
}
