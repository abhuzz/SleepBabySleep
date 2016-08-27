//
//  FakeImplementations.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
@testable import SleepBabySleep

class FakeAudioPlayer: AudioPlayer {
    
    var playCalled = false
    var stopCalled = false
    var timesPlayCalled = 0
    
    func play(withUrl: NSURL) {
        playCalled = true
        timesPlayCalled += 1
    }
    
    func stop() {
        stopCalled = true
    }
}

class FakeTimer: Timer {
    
    func start(durationInSeconds: Double, callDelegateWhenExpired: TimerExpiredDelegate) {
        
    }
}

class FakeAppBundle: AppBundle {
    
    func file(withName: String, andExtension: String) -> NSURL {
        return NSURL()
    }
}