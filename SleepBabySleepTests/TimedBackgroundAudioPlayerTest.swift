//
//  SleepBabySleepTests.swift
//  SleepBabySleepTests
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import SleepBabySleep


class FakeAudioPlayer: AudioPlayer {
    
    var playCalled = false
    
    func play(withUrl: NSURL) {
        playCalled = true
    }
    
    func stop() {
        
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

class TimedBackgroundAudioPlayerTest: XCTestCase {
    
    var fakeAudioPlayer: FakeAudioPlayer?
    var fakeTimer: FakeTimer?
    var testInstance: TimedBackgroundAudioPlayer?
    
    var aSoundFile = SoundFile(Name: "test", File: "none", Extension: "mp3")
    
    
    override func setUp() {
        super.setUp()
        
        fakeAudioPlayer = FakeAudioPlayer()
        fakeTimer = FakeTimer()
        
        testInstance =
            TimedBackgroundAudioPlayer(audioPlayer: fakeAudioPlayer!, timer: fakeTimer!, appBundle: FakeAppBundle())
    }

    
    func testToggleStatusWithoutSelectedSoundFileDoesNotCallAudioPlayer() {
        
        testInstance!.togglePlayState()
        
        XCTAssertFalse(fakeAudioPlayer!.playCalled)
    }
    
    func testToggleStateStartsAudioPlayback() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.togglePlayState()
        
        XCTAssertTrue(fakeAudioPlayer!.playCalled)
    }
    
}
