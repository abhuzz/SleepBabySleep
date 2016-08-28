//
//  PlaybackDuration.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

protocol PlaybackDuration {
    func infinite() -> Bool
    func totalSeconds() -> Double

}

class PlaybackDurationMinutes: PlaybackDuration {
    
    private var durationInMinutes: Int
    
    init(durationInMinutes: Int) {
        self.durationInMinutes = durationInMinutes
    }
    
    func infinite() -> Bool {
        return false
    }
    
    func totalSeconds() -> Double {
        return Double(durationInMinutes * 60)
    }
}

class PlaybackDurationInifinite: PlaybackDuration {
    
    func infinite() -> Bool {
        return true
    }
    
    func totalSeconds() -> Double {
        return 0.0
    }
}