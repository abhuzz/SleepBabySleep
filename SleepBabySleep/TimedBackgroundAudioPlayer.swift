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
    
    init(audioPlayer: AudioPlayer, timer: Timer) {
        
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
    
    func restartPlayingSound() {
        
        self.stopPlayingSound()
        self.startPlayingSound()
    }
    
    
    private func startPlayingSound() {
    
        guard let soundFileToPlay = self.selectedSoundFile else { return }
    
        let url = NSBundle.mainBundle().URLForResource(soundFileToPlay.File, withExtension: "mp3")!
    
        audioPlayer.play(url)
        
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