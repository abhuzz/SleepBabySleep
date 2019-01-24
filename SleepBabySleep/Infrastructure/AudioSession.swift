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
    
    private let session = AVAudioSession.sharedInstance()
    
    private var microphoneAvailable = false
    
    
    func openForPlayback() throws {
     
        try session.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: AVAudioSession.Mode.default)
        try session.setActive(true)
//        try session.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: [AVAudioSession.Mode.default,AVAudioSession.Mode.spokenAudio])
        NSLog("AVAudioSessionFacade.openForPlayback()")
    }
    
    func openForRecording() throws {
        
        try session.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)), mode: AVAudioSession.Mode.default)
        try session.setActive(true)
//        try session.setCategory(convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord), with: [.defaultToSpeaker, .allowBluetooth])
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
