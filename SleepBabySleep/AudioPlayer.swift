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
    var stateDelegate: AudioPlayerStateDelegate? { get set }
    
    func play(withUrl: NSURL)
    func stop()
}

protocol AudioPlayerStateDelegate {
    func playbackCancelled()
}

class AVAudioPlayerFacade: AudioPlayer {
    
    private var player: AVAudioPlayer?
    var stateDelegate: AudioPlayerStateDelegate?
    
    init() {
        
        let nc = NSNotificationCenter.defaultCenter()
        let session = AVAudioSession.sharedInstance()
        
        nc.addObserver(self, selector: #selector(AVAudioPlayerFacade.notificationAudioSessionInterruptedReceived(_:)), name: AVAudioSessionInterruptionNotification, object: session)
        nc.addObserver(self, selector: #selector(AVAudioPlayerFacade.notificationAudioSessionRouteChangedReceived(_:)), name: AVAudioSessionRouteChangeNotification, object: session)
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
    
    @objc private func notificationAudioSessionInterruptedReceived(notification: NSNotification) {
     
        NSLog("notificationAudioSessionInterruptedReceived")
        
        if let info = notification.userInfo {
            
            let type = AVAudioSessionInterruptionType(rawValue: info[AVAudioSessionInterruptionTypeKey] as! UInt)
            
            if type == .Began {
                
                stop()
                
                if let delegate = self.stateDelegate {
                    delegate.playbackCancelled()
                }
            }
        }
    }
    
    @objc private func notificationAudioSessionRouteChangedReceived(notification: NSNotification) {
     
        NSLog("notificationAudioSessionRouteChangedReceived")
        
        guard let info = notification.userInfo else { return }
        
        let reason = AVAudioSessionRouteChangeReason(rawValue: info[AVAudioSessionRouteChangeReasonKey] as! UInt)
        
        if reason == .OldDeviceUnavailable {
            
            let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
            let previousOutput = previousRoute!.outputs.first!
            
            // Disable playback when previously headphones were connceted
            if previousOutput.portType == AVAudioSessionPortHeadphones {
                
                stop()
                
                if let delegate = self.stateDelegate {
                    delegate.playbackCancelled()
                }
            }
        }
    }
}