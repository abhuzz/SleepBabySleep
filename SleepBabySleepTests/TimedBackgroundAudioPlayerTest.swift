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
    
    var fakeAudioSession: FakeAudioSession?
    var fakeAudioPlayer: FakeAudioPlayer?
    var fakeTimer: FakeTimer?
    var testInstance: TimedBackgroundAudioPlayer?
    var fakeBackgroundAudioPlayerStateDelegate: FakeBackgroundAudioPlayerStateDelegate?
    
    var aSoundFile = FakeSoundFile()
    var anotherSoundFile = FakeSoundFile()
    var defaultPlaybackDuration = PlaybackDurationMinutes(durationInMinutes: 1)
    
    
    override func setUp() {
        super.setUp()
        
        fakeAudioSession = FakeAudioSession()
        fakeAudioPlayer = FakeAudioPlayer()
        fakeTimer = FakeTimer()
        fakeBackgroundAudioPlayerStateDelegate = FakeBackgroundAudioPlayerStateDelegate()
        
        testInstance =
            TimedBackgroundAudioPlayer(audioSession: fakeAudioSession!, audioPlayer: fakeAudioPlayer!, timer: fakeTimer!)
        
        testInstance?.stateDelegate = fakeBackgroundAudioPlayerStateDelegate
    }

    
    func testToggleStatusWithoutSelectedSoundFileDoesNotCallAudioPlayer() {
        
        testInstance!.playbackDuration = defaultPlaybackDuration
        
        testInstance!.togglePlayState()
        
        XCTAssertFalse(fakeAudioPlayer!.playCalled)
    }
    
    func testToggleStateStartsAudioPlayback() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.playbackDuration = defaultPlaybackDuration
        
        testInstance!.togglePlayState()
        
        XCTAssertTrue(fakeAudioPlayer!.playCalled)
    }
    
    func testToggleStateTiceCallsPlayAndStopAudio() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.playbackDuration = defaultPlaybackDuration
        
        testInstance!.togglePlayState()
        testInstance!.togglePlayState()
        
        XCTAssertTrue(fakeAudioPlayer!.playCalled)
        XCTAssertTrue(fakeAudioPlayer!.stopCalled)
    }
    
    func testToggleStateThreeTimesCallsPlayAudio2Times() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.playbackDuration = defaultPlaybackDuration
        
        testInstance!.togglePlayState()
        testInstance!.togglePlayState()
        testInstance!.togglePlayState()
        
        XCTAssertEqual(2, fakeAudioPlayer!.timesPlayCalled)
    }
    
    
    func testStateChangedDelegateCalledForPlaying() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.playbackDuration = defaultPlaybackDuration
        
        testInstance!.togglePlayState()
        
        assertLastPlayStateIs(.Playing)
    }
    
    func testStateChangeDeledageCalledForStop() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.playbackDuration = defaultPlaybackDuration
        
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
        testInstance!.playbackDuration = defaultPlaybackDuration
        
        XCTAssertFalse(fakeAudioPlayer!.playCalled)
    }
    
    func testChangeSoundFileWhilePlayingRestartsPlayer() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.playbackDuration = defaultPlaybackDuration
        
        testInstance!.togglePlayState()
        testInstance!.selectedSoundFile = anotherSoundFile
        
        XCTAssertTrue(fakeAudioPlayer!.stopCalled)
        XCTAssertEqual(2, fakeAudioPlayer!.timesPlayCalled)
    }
    
    
    func testCallsTimerWithExpectedDuration() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.playbackDuration = PlaybackDurationMinutes(durationInMinutes: 1)
        
        testInstance!.togglePlayState()
        
        XCTAssertTrue(fakeTimer!.calledStart)
        XCTAssertEqual(Double(60), fakeTimer!.calledWithDurationInSeconds)
    }
    
    func testStopsTimerWhenPlaybackIsPaused() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.playbackDuration = PlaybackDurationMinutes(durationInMinutes: 1)
        
        testInstance!.togglePlayState()
        testInstance!.togglePlayState()
        
        XCTAssertTrue(fakeTimer!.calledStart)
        XCTAssertTrue(fakeTimer!.calledStop)
    }
    
    func testDoesNotStartTimeWhenPlaybackDurationIsInifinite() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.playbackDuration = PlaybackDurationInifinite()
        
        testInstance!.togglePlayState()
        
        XCTAssertFalse(fakeTimer!.calledStart)
    }
    
    func testChangePlaybackDurationWhilePlayingRestartsPlayback() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.playbackDuration = PlaybackDurationInifinite()
        testInstance!.togglePlayState()
        
        XCTAssertEqual(0, fakeTimer?.calledWithDurationInSeconds)
        
        testInstance!.playbackDuration = defaultPlaybackDuration
        
        XCTAssertEqual(defaultPlaybackDuration.totalSeconds(), fakeTimer?.calledWithDurationInSeconds)
    }
    
    
    func testOpensAudioSesssionBeforeStartingPlayback() {
        
        testInstance!.selectedSoundFile = aSoundFile
        testInstance!.playbackDuration = PlaybackDurationInifinite()
        testInstance!.togglePlayState()
        
        XCTAssertTrue(fakeAudioSession!.calledOpenForPlayback)
        XCTAssertEqual(0, fakeAudioSession!.timesCloseCalled)
    }
}
