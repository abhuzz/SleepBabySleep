//
//  BackgroundAudioPlayer.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

protocol BackgroundAudioPlayerStateDelegate {
    func playStateChanged(playState: PlayState)
}

class TimedBackgroundAudioPlayer {

    private var audioPlayer: AudioPlayer
    private var timer: Timer
    private var appBundle: AppBundle
    
    var playState: PlayState = .Paused
    var stateDelegate: BackgroundAudioPlayerStateDelegate?
    
    var selectedSoundFile: SoundFile? {
        didSet {
            restartAudioIfIsPlayingSound()
        }
    }
    
    var playbackDuration: PlaybackDuration?
    
    
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
    
    
    private func restartAudioIfIsPlayingSound() {
        
        guard playState == .Playing else { return }
        
        stopPlayingSound()
        startPlayingSound()
    }
    
    private func startPlayingSound() {
    
        guard let soundFileToPlay = self.selectedSoundFile else { return }
        
        guard let playbackDuration = self.playbackDuration else { return }
        
    
        audioPlayer.play(urlForSoundFile(soundFileToPlay))
        
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
    
    private func urlForSoundFile(soundFile: SoundFile) -> NSURL {
        
        return appBundle.file(soundFile.File, andExtension: soundFile.Extension)
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