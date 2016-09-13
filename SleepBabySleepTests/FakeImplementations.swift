//
//  FakeImplementations.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import UIKit
@testable import SleepBabySleep

class FakeAudioSession: AudioSession {
    
    private(set) var calledOpenForPlayback = false
    private(set) var calledOpenForRecording = false
    private(set) var timesCloseCalled = 0
    
    func openForPlayback() throws {
        calledOpenForPlayback = true
    }
    
    func openForRecording() throws {
        calledOpenForRecording = true
    }
    
    func close() throws {
        timesCloseCalled += 1
    }
    
    func microphoneAvailble() -> Bool {
        return false
    }
}

class FakeAudioPlayer: AudioPlayer {
    
    var stateDelegate: AudioPlayerStateDelegate?
    
    private(set) var playCalled = false
    private(set) var stopCalled = false
    private(set) var timesPlayCalled = 0
    
    func play(_ withUrl: URL) {
        playCalled = true
        timesPlayCalled += 1
    }
    
    func stop() {
        stopCalled = true
    }
}

class FakeTimer: SleepBabySleep.Timer {
    
    private(set) var calledStart = false
    private(set) var calledStop = false
    private(set) var calledWithDurationInSeconds = 0.0
    
    func start(_ durationInSeconds: Double, callDelegateWhenExpired: TimerExpiredDelegate) {
        
        calledStart = true
        calledWithDurationInSeconds = durationInSeconds
    }
    
    func stop() {
    
        calledStop = true
    }
}

class FakeBackgroundAudioPlayerStateDelegate: BackgroundAudioPlayerStateDelegate {
    
    private(set) var lastPlayState: PlayState?
    
    func playStateChanged(_ playState: PlayState) {
        lastPlayState = playState
    }
}

class FakeSoundFile: SoundFile, Equatable {
    var Identifier = UUID()
    var Name = String()
    var URL = Foundation.URL(fileURLWithPath: "")
    var Image = UIImage()
    var Deletable = false
}

func ==(lhs: FakeSoundFile, rhs: FakeSoundFile) -> Bool {
    return type(of: lhs).self === type(of: rhs).self
}
