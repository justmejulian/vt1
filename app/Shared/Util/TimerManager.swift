//
//  TimerManager.swift
//  vt1
//
//  Created by Julian Visser on 08.04.2024.
//

import Foundation
import OSLog

// Timer needs to run on main to make sure it updated correctly
class TimerManager {

    @Published var counter = 0

    var timer: Timer? = nil

    @MainActor
    func start() {
        Logger.viewCycle.debug("Starting Timer")
        if timer != nil {
            Logger.viewCycle.warning("Timer already running")
        }
        counter = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Update the counter every second
            DispatchQueue.main.async {
                self.counter += 1
            }
        }
    }
    

    @MainActor 
    func stop() {
        Logger.viewCycle.debug("Stopping Timer")
        if timer == nil {
            Logger.viewCycle.warning("No Timer running")
        }
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        Logger.viewCycle.debug("Reseting Timer")
        counter = 0
    }
    
}
