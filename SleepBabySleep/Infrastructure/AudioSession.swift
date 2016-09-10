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
}

class AVAudioSessionFacade: AudioSession {
    
    private let session = AVAudioSession.sharedInstance()
    
    private(set) var microphoneAvailable = false
    
    
    func openForPlayback() throws {
     
        try session.setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
        try session.setActive(true)
        
        NSLog("AVAudioSessionFacade.openForPlayback()")
    }
    
    func openForRecording() throws {
        
        try session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: [.DefaultToSpeaker, .AllowBluetooth])
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
}