//
//  BackgroundAudioPlayer.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

enum PlayState {
    case Paused
    case Playing
}

protocol BackgroundAudioPlayer {
    var stateDelegate: BackgroundAudioPlayerStateDelegate? { get set }
    var playbackDuration: PlaybackDuration? { get set }
    var selectedSoundFile: SoundFile? { get set }
    var playState: PlayState { get }
    
    func togglePlayState()
}

protocol BackgroundAudioPlayerStateDelegate {
    func playStateChanged(playState: PlayState)
}

class TimedBackgroundAudioPlayer: BackgroundAudioPlayer {

    private var audioSession: AudioSession
    private var audioPlayer: AudioPlayer
    private var timer: Timer
    
    
    var playState: PlayState = .Paused
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
    
    
    init(audioSession: AudioSession, audioPlayer: AudioPlayer, timer: Timer) {
        
        self.audioSession = audioSession
        self.audioPlayer = audioPlayer
        self.timer = timer
    }
    
    func togglePlayState() {
        
        if playState == .Playing {
            stopPlayingSound()
        } else {
            startPlayingSound()
        }
    }
    
    
    private func restartAudioIfIsPlayingSound() {
        
        guard playState == .Playing else { return }
        
        stopPlayingSound()
        startPlayingSound()
    }
    
    private func startPlayingSound() {
    
        guard let soundFileToPlay = self.selectedSoundFile else { return }
        
        guard let playbackDuration = self.playbackDuration else { return }
        
        audioPlayer.stateDelegate = self
        
        audioPlayer.play(soundFileToPlay.URL)
        
        if !playbackDuration.infinite() {
            timer.start(playbackDuration.totalSeconds(), callDelegateWhenExpired: self)
        }
        
        changePlayState(.Playing)
    }
    
    private func stopPlayingSound() {
        
        audioPlayer.stop()
        timer.stop()
        
        changePlayState(.Paused)
    }
    
    private func changePlayState(newPlayState: PlayState) {
        
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