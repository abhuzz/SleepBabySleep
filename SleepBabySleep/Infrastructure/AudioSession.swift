//
//  AudioSession.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 10/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioSession {
    func openForPlayback() throws
    func openForRecording() throws
    func close() throws
    func microphoneAvailble() -> Bool
}

class AVAudioSessionFacade: AudioSession {
    
    fileprivate let session = AVAudioSession.sharedInstance()
    
    fileprivate var microphoneAvailable = false
    
    
    func openForPlayback() throws {
     
        try session.setCategory(AVAudioSessionCategoryPlayback, with: [])
        try session.setActive(true)
        
        NSLog("AVAudioSessionFacade.openForPlayback()")
    }
    
    func openForRecording() throws {
        
        try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)
        
        session.requestRecordPermission({(granted: Bool)-> Void in
            self.microphoneAvailable = granted
        })

        NSLog("AVAudioSessionFacade.openForRecording() - MicrophoneAccessGranted: \(microphoneAvailable)")
    }
    
    func close() throws {
        
        try session.setActive(false)
        
        NSLog("AVAudioSessionFacade.close()")
    }
    
    func microphoneAvailble() -> Bool {
        return microphoneAvailable
    }
}
