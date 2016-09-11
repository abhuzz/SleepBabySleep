//
//  AudioRecorder.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 31/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioRecorderDelegate {
    
    func recordingFinished()
}

class AudioRecorder: NSObject { // for AVAudioRecorderDelegate :-(
    
    private let recordSettings = [
                        AVFormatIDKey: Int(kAudioFormatLinearPCM),
                        AVSampleRateKey: 44100.0,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
                    ]
    
    private var audioRecorder: AVAudioRecorder?
    
    var delegate: AudioRecorderDelegate?
    
    var currentTime: UInt {
        get {
            guard let audioRecorder = audioRecorder else { return 0 }
            
            return UInt(audioRecorder.currentTime)
        }
    }
    
    override init() {
        
        super.init()
        
        let nc = NSNotificationCenter.defaultCenter()
        let session = AVAudioSession.sharedInstance()
        
        nc.addObserver(self, selector: #selector(AudioRecorder.notificationAudioSessionInterruptedReceived(_:)), name: AVAudioSessionInterruptionNotification, object: session)
        nc.addObserver(self, selector: #selector(AudioRecorder.notificationAudioSessionRouteChangedReceived(_:)), name: AVAudioSessionRouteChangeNotification, object: session)
    }
    
    
    func start(intoURL: NSURL) {
        
        NSLog("start() with URL: \(intoURL.absoluteString)")
        
        do {
            audioRecorder = try AVAudioRecorder(URL: intoURL, settings: recordSettings as! [String : AnyObject])
            audioRecorder!.delegate = self
            audioRecorder!.prepareToRecord()
        } catch {
            NSLog("Error creating audioRecorder.")
            return
        }
        
        audioRecorder!.record()
    }
    
    func stop() {
        
        NSLog("stop()")
        
        audioRecorder?.stop()
    }
    
    private func triggerDelegateRecordingStopped() {

        guard let delegate = self.delegate else { return }
        
        delegate.recordingFinished()
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        NSLog("audioRecorderDidFinishRecording() -> \(flag)")
        
        triggerDelegateRecordingStopped()
    }
}

extension AudioRecorder { // AVAudioSessionInterrution / route changed

    @objc private func notificationAudioSessionInterruptedReceived(notification: NSNotification) {
        
        NSLog("AudioRecorder.notificationAudioSessionInterruptedReceived")
        
        if let info = notification.userInfo {
            
            let type = AVAudioSessionInterruptionType(rawValue: info[AVAudioSessionInterruptionTypeKey] as! UInt)
            
            if type == .Began {
                
                stop()
                triggerDelegateRecordingStopped()
            }
        }
    }
    
    @objc private func notificationAudioSessionRouteChangedReceived(notification: NSNotification) {
        
        NSLog("AudioRecorder.notificationAudioSessionRouteChangedReceived")
        
        guard let info = notification.userInfo else { return }
        
        let reason = AVAudioSessionRouteChangeReason(rawValue: info[AVAudioSessionRouteChangeReasonKey] as! UInt)
        
        if reason == .OldDeviceUnavailable {
            
            stop()
            triggerDelegateRecordingStopped()

        }
    }

}