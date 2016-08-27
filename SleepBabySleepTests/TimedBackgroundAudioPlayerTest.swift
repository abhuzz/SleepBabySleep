//
//  SleepBabySleepTests.swift
//  SleepBabySleepTests
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import SleepBabySleep


class TimedBackgroundAudioPlayerTest: XCTestCase {
    
    var fakeAudioPlayer: FakeAudioPlayer?
    var fakeTimer: FakeTimer?
    var testInstance: TimedBackgroundAudioPlayer?
    var fakeBackgroundAudioPlayerStateDelegate: FakeBackgroundAudioPlayerStateDelegate?
    
    var aSoundFile = SoundFile(Name: "test", File: "none", Extension: "mp3")
    var anotherSoundFile = SoundFile(Name: "test2", File: "nothing", Extension: "wav")
    
    
    override func setUp() {
        super.setUp()
        
        fakeAudioPlayer = FakeAudioPlayer()
        fakeTimer = FakeTimer()
        fakeBackgroundAudioPlayerStateDelegate = FakeBackgroundAudioPlayerStateDelegate()
        
        testInstance =
            TimedBackgroundAudioPlayer(audioPlayer: fakeAudioPlayer!, timer: fakeTimer!, appBundle: FakeAppBundle())
        
        testInstance?.stateDelegate = fakeBackgroundAudioPlayerStateDelegate
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
    
    func testToggleStateTiceCallsPlayAndStopAudio() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.togglePlayState()
        testInstance!.togglePlayState()
        
        XCTAssertTrue(fakeAudioPlayer!.playCalled)
        XCTAssertTrue(fakeAudioPlayer!.stopCalled)
    }
    
    func testToggleStateThreeTimesCallsPlayAudio2Times() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.togglePlayState()
        testInstance!.togglePlayState()
        testInstance!.togglePlayState()
        
        XCTAssertEqual(2, fakeAudioPlayer!.timesPlayCalled)
    }
    
    
    func testStateChangedDelegateCalledForPlaying() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.togglePlayState()
        
        assertLastPlayStateIs(.Playing)
    }
    
    func testStateChangeDeledageCalledForStop() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.togglePlayState()
        testInstance!.togglePlayState()
        
        assertLastPlayStateIs(.Paused)

    }
    
    func assertLastPlayStateIs(expectedPlayState: PlayState) {
        
        XCTAssertNotNil(fakeBackgroundAudioPlayerStateDelegate?.lastPlayState)
        
        guard let lastPlayState = fakeBackgroundAudioPlayerStateDelegate?.lastPlayState else { return }
        
        XCTAssertEqual(expectedPlayState, lastPlayState)
    }
    
    
    func testChangeSoundFileWhenNotPlayingDoesntStartPlaying() {
        
        testInstance!.selectedSoundFile = aSoundFile
        
        XCTAssertFalse(fakeAudioPlayer!.playCalled)
    }
    
    func testChangeSoundFileWhilePlayingRestartsPlayer() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.togglePlayState()
        testInstance!.selectedSoundFile = anotherSoundFile
        
        XCTAssertTrue(fakeAudioPlayer!.stopCalled)
        XCTAssertEqual(2, fakeAudioPlayer!.timesPlayCalled)
    }
}
