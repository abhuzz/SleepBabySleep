//
//  BackgroundAudioPlayer.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

protocol BackgroundAudioPlayerStateDelegate {
    func playStateChanged(playState: PlayState)
}

class TimedBackgroundAudioPlayer {

    var playState: PlayState = .Paused
    var stateDelegate: BackgroundAudioPlayerStateDelegate?
    var selectedSoundFile: SoundFile?
    
    private var player: AVAudioPlayer?
    private var timer = NSTimer()

    init() {
        
        initializeBackgroundAudioPlayback()
    }
    
    func initializeBackgroundAudioPlayback() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                NSLog("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                NSLog("AVAudioSession is Active")
            } catch let error as NSError {
                NSLog(error.localizedDescription)
            }
        } catch let error as NSError {
            NSLog(error.localizedDescription)
        }
        
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
    
        do {
            player = try AVAudioPlayer(contentsOfURL: url)
    
            guard let player = player else { return }
    
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
        
        timer =
            NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(BackgroundAudioPlayer.playbackTimerExpired), userInfo: nil, repeats: false)
        
        playState = .Playing
        
        informDelegateOverPlayStateChange()
    }
    
    private func stopPlayingSound() {
        
        guard let player = self.player else { return }
        
        player.pause()
        
        playState = .Paused
        
        informDelegateOverPlayStateChange()
    }
    
    private func informDelegateOverPlayStateChange() {
        
        guard let delegate = stateDelegate else { return }
        
        delegate.playStateChanged(playState)
    }
    
    @objc func playbackTimerExpired() {
        
        NSLog("playbackTimerExpired()")
        
        self.stopPlayingSound()
    }
}