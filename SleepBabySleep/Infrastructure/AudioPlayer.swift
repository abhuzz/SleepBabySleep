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
    
    func play(_ withUrl: URL)
    func stop()
}

protocol AudioPlayerStateDelegate {
    func playbackCancelled()
    func playbackStopped()
}

class AVAudioPlayerFacade: NSObject, AudioPlayer { // for AVAudioRecorderDelegate :-( {
    
    fileprivate var player: AVAudioPlayer?
    fileprivate var numberOfLoops: Int
    
    var stateDelegate: AudioPlayerStateDelegate?
    
    internal init(numberOfLoops: Int) {
        
        self.numberOfLoops = numberOfLoops
        
        super.init()
        
        let nc = NotificationCenter.default
        let session = AVAudioSession.sharedInstance()
        
        nc.addObserver(self, selector: #selector(AVAudioPlayerFacade.notificationAudioSessionInterruptedReceived(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: session)
        nc.addObserver(self, selector: #selector(AVAudioPlayerFacade.notificationAudioSessionRouteChangedReceived(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: session)
    }
    
    override convenience init() {
        self.init(numberOfLoops: -1)
    }
    
    func play(_ withUrl: URL) {
        
        do {
            player = try AVAudioPlayer(contentsOf: withUrl)
            
            guard let player = player else { return }
            
            player.delegate = self
            player.numberOfLoops = numberOfLoops
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func stop() {
        
        guard let player = self.player else { return }
        
        player.pause()
        
        guard let delegate = self.stateDelegate else { return }
        
        delegate.playbackStopped()
    }
    
    fileprivate func triggerDelegatePlaybackStopped() {
        
        if let delegate = self.stateDelegate {
            delegate.playbackCancelled()
        }
    }
    
    @objc fileprivate func notificationAudioSessionInterruptedReceived(_ notification: Notification) {
     
        NSLog("AVAudioPlayerFacade.notificationAudioSessionInterruptedReceived")
        
        if let info = (notification as NSNotification).userInfo {
            
            let type = AVAudioSessionInterruptionType(rawValue: info[AVAudioSessionInterruptionTypeKey] as! UInt)
            
            if type == .began {
                
                stop()
                triggerDelegatePlaybackStopped()
            }
        }
    }
    
    @objc fileprivate func notificationAudioSessionRouteChangedReceived(_ notification: Notification) {
     
        NSLog("AVAudioPlayerFacade.notificationAudioSessionRouteChangedReceived")
        
        guard let info = (notification as NSNotification).userInfo else { return }
        
        let reason = AVAudioSessionRouteChangeReason(rawValue: info[AVAudioSessionRouteChangeReasonKey] as! UInt)
        
        if reason == .oldDeviceUnavailable {
            
            let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
            let previousOutput = previousRoute!.outputs.first!
            
            // Disable playback when previously headphones were connceted
            if previousOutput.portType == AVAudioSessionPortHeadphones {
                
                stop()
                triggerDelegatePlaybackStopped()
            }
        }
    }
}

extension AVAudioPlayerFacade: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        NSLog("AudioPlayer finished playing -> \(flag)")
        
        triggerDelegatePlaybackStopped()
    }
}
