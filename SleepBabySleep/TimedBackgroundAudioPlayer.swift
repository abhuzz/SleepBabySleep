//
//  BackgroundAudioPlayer.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

import MediaPlayer

protocol BackgroundAudioPlayerStateDelegate {
    func playStateChanged(playState: PlayState)
}

class TimedBackgroundAudioPlayer {

    var playState: PlayState = .Paused
    var stateDelegate: BackgroundAudioPlayerStateDelegate?
    var selectedSoundFile: SoundFile?
    
    private var audioPlayer: AudioPlayer
    private var timer: Timer
    private var appBundle: AppBundle
    
    init(audioPlayer: AudioPlayer, timer: Timer, appBundle: AppBundle) {
        
        self.audioPlayer = audioPlayer
        self.timer = timer
        self.appBundle = appBundle
    }
    
    
    func togglePlayState() {
        
        if playState == .Playing {
            stopPlayingSound()
        } else {
            startPlayingSound()
        }
    }
    
    func restartPlayingSound() {
        
        self.stopPlayingSound()
        self.startPlayingSound()
    }
    
    
    private func startPlayingSound() {
    
        guard let soundFileToPlay = self.selectedSoundFile else { return }
    
        audioPlayer.play(
            appBundle.file(soundFileToPlay.File, andExtension: soundFileToPlay.Extension))
        
        timer.start(10.0, callDelegateWhenExpired: self)
        
        playState = .Playing
        
        informDelegateOverPlayStateChange()
    }
    
    private func stopPlayingSound() {
        
        audioPlayer.stop()
        
        playState = .Paused
        
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