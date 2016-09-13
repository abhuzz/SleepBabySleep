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
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ] as [String : Any]
    
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
        
        let nc = NotificationCenter.default
        let session = AVAudioSession.sharedInstance()
        
        nc.addObserver(self, selector: #selector(AudioRecorder.notificationAudioSessionInterruptedReceived(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: session)
        nc.addObserver(self, selector: #selector(AudioRecorder.notificationAudioSessionRouteChangedReceived(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: session)
    }
    
    
    func start(_ intoURL: URL) {
        
        NSLog("start() with URL: \(intoURL.absoluteString)")
        
        do {
            audioRecorder = try AVAudioRecorder(url: intoURL, settings: recordSettings as [String : AnyObject])
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
    
    fileprivate func triggerDelegateRecordingStopped() {

        guard let delegate = self.delegate else { return }
        
        delegate.recordingFinished()
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        NSLog("audioRecorderDidFinishRecording() -> \(flag)")
        
        triggerDelegateRecordingStopped()
    }
}

extension AudioRecorder { // AVAudioSessionInterrution / route changed

    @objc fileprivate func notificationAudioSessionInterruptedReceived(_ notification: Notification) {
        
        NSLog("AudioRecorder.notificationAudioSessionInterruptedReceived")
        
        if let info = (notification as NSNotification).userInfo {
            
            let type = AVAudioSessionInterruptionType(rawValue: info[AVAudioSessionInterruptionTypeKey] as! UInt)
            
            if type == .began {
                
                stop()
                triggerDelegateRecordingStopped()
            }
        }
    }
    
    @objc fileprivate func notificationAudioSessionRouteChangedReceived(_ notification: Notification) {
        
        NSLog("AudioRecorder.notificationAudioSessionRouteChangedReceived")
        
        guard let info = (notification as NSNotification).userInfo else { return }
        
        let reason = AVAudioSessionRouteChangeReason(rawValue: info[AVAudioSessionRouteChangeReasonKey] as! UInt)
        
        if reason == .oldDeviceUnavailable {
            
            stop()
            triggerDelegateRecordingStopped()

        }
    }

}
