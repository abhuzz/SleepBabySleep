//
//  PlaybackDuration.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class PlaybackDuration {
    
    private var durationInMinutes: Int
    
    init(durationInMinutes: Int) {
        self.durationInMinutes = durationInMinutes
    }
    
    func totalSeconds() -> Double{
        return Double(durationInMinutes * 60)
    }
}