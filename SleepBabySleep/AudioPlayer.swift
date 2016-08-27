//
//  AudioPlayer.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayer {
    func play(withUrl: NSURL)
    func stop()
}

class AVAudioPlayerFacade: AudioPlayer {
    
    private var player: AVAudioPlayer?
    
    init() {
        
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
    
    func play(withUrl: NSURL) {
        
        do {
            player = try AVAudioPlayer(contentsOfURL: withUrl)
            
            guard let player = player else { return }
            
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func stop() {
        
        guard let player = self.player else { return }
        
        player.pause()
    }
}