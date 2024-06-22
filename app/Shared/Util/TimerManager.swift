//
//  TimerManager.swift
//  vt1
//
//  Created by Julian Visser on 08.04.2024.
//

import Foundation
import OSLog

// Timer needs to run on main to make sure it updated correctly
@MainActor
class TimerManager: ObservableObject{
    
    // todo make private(set)
    @Published var counter = 0
    
    var timer: Timer? = nil
    
    func start() {
        Logger.viewCycle.debug("Starting Timer")
        if timer != nil {
            Logger.viewCycle.warning("Timer already running")
        }
        
        self.reset()
        
        // Update the counter every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // todo build in max time
            Task(priority: .high) {
                await self.increaseCounter()
            }
        }
    }
    
    func increaseCounter() {
        self.counter += 1
    }
    
    func stop() {
        Logger.viewCycle.debug("Stopping Timer")
        if timer == nil {
            Logger.viewCycle.warning("No Timer running")
            return
        }
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        Logger.viewCycle.debug("Reseting Timer")
        counter = 0
    }
    
}
