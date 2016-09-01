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
    
    var stateDelegate: AudioPlayerStateDelegate?
    
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
    
    var calledStart = false
    var calledStop = false
    var calledWithDurationInSeconds = 0.0
    
    func start(durationInSeconds: Double, callDelegateWhenExpired: TimerExpiredDelegate) {
        
        calledStart = true
        calledWithDurationInSeconds = durationInSeconds
    }
    
    func stop() {
    
        calledStop = true
    }
}

class FakeBackgroundAudioPlayerStateDelegate: BackgroundAudioPlayerStateDelegate {
    
    var lastPlayState: PlayState?
    
    func playStateChanged(playState: PlayState) {
        lastPlayState = playState
    }
}

class FakeSoundFile: SoundFile, Equatable {
    var Name = String()
    var URL = NSURL()
}

func ==(lhs: FakeSoundFile, rhs: FakeSoundFile) -> Bool {
    return lhs.dynamicType.self === rhs.dynamicType.self
}