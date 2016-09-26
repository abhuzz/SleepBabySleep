//
//  BackgroundAudioPlayer.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

enum PlayState {
    case paused
    case playing
}

protocol BackgroundAudioPlayer {
    var stateDelegate: BackgroundAudioPlayerStateDelegate? { get set }
    var playbackDuration: PlaybackDuration? { get set }
    var selectedSoundFile: SoundFile? { get set }
    var playState: PlayState { get }
    
    var currentTimePlayed: Int { get }
    var currentRemainingTime: Int { get }
    var currentPercentagePlayed: Double { get }
    
    func togglePlayState()
}

protocol BackgroundAudioPlayerStateDelegate {
    func playStateChanged(_ playState: PlayState)
}

class TimedBackgroundAudioPlayer: BackgroundAudioPlayer {

    private var audioSession: AudioSession
    private var audioPlayer: AudioPlayer
    private var timer: Timer
    private var timerStarted: Date?
    
    
    var playState: PlayState = .paused
    var stateDelegate: BackgroundAudioPlayerStateDelegate?
    
    var selectedSoundFile: SoundFile? {
        didSet {
            restartAudioIfIsPlayingSound()
        }
    }
    
    var playbackDuration: PlaybackDuration? {
        didSet {
            restartAudioIfIsPlayingSound()
        }
    }
    
    var currentTimePlayed: Int {
        get {
            guard let started = timerStarted else { return 0 }
            let playedInterval = DateInterval(start: started, end: Date())
            return Int(playedInterval.duration)
        }
    }
    
    var currentRemainingTime: Int {
        get {
            guard let playbackDuration = self.playbackDuration else { return 0 }
            
            if playbackDuration.infinite() {
                return 0
            } else {
                return playbackDuration.totalSeconds() - currentTimePlayed
            }
        }
    }
    
    var currentPercentagePlayed: Double {
        get {
            guard let playbackDuration = self.playbackDuration else { return 0.0 }
            
            if playbackDuration.infinite() {
                return 0.0
            } else {
                return Double(currentTimePlayed) / ( Double(playbackDuration.totalSeconds() ) / 100.0 )
            }
        }
    }
    
    
    init(audioSession: AudioSession, audioPlayer: AudioPlayer, timer: Timer) {
        
        self.audioSession = audioSession
        self.audioPlayer = audioPlayer
        self.timer = timer
    }
    
    func togglePlayState() {
        
        if playState == .playing {
            stopPlayingSound()
        } else {
            startPlayingSound()
        }
    }
    
    
    private func restartAudioIfIsPlayingSound() {
        
        guard playState == .playing else { return }
        
        stopPlayingSound()
        startPlayingSound()
    }
    
    private func startPlayingSound() {
    
        guard let soundFileToPlay = self.selectedSoundFile else { return }
        
        guard let playbackDuration = self.playbackDuration else { return }
        
        do {
            try audioSession.openForPlayback()
            
            audioPlayer.stateDelegate = self
            audioPlayer.play(soundFileToPlay.URL)
            
            if !playbackDuration.infinite() {
                timer.start(Double(playbackDuration.totalSeconds()), callDelegateWhenExpired: self)
                timerStarted = Date()
            }
            
            changePlayState(.playing)
        
        } catch let error as NSError {
            NSLog("Failed to play sound: \(error.localizedDescription)")
        }
    }
    
    fileprivate func stopPlayingSound() {
        
        timer.stop()
        audioPlayer.stop()
        
        do {
            try audioSession.close()
        } catch let error as NSError {
            NSLog("Failed closing audioSession: \(error.localizedDescription)")
        }
        
        changePlayState(.paused)
    }
    
    private func changePlayState(_ newPlayState: PlayState) {
        
        playState = newPlayState
        
        informDelegateOverPlayStateChange()
    }
    
    private func informDelegateOverPlayStateChange() {
        
        guard let delegate = stateDelegate else { return }
        
        delegate.playStateChanged(playState)
    }
}

extension TimedBackgroundAudioPlayer: TimerExpiredDelegate {
    
    func timerExpired() {
        
        NSLog("timerExpired()")
        
        self.stopPlayingSound()
    }
}

extension TimedBackgroundAudioPlayer: AudioPlayerStateDelegate {
    
    func playbackCancelled() {
        
        stopPlayingSound()
    }
    
    func playbackStopped() { }
}
