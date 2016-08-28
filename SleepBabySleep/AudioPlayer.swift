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