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
        
        audioRecorder!.stop()
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        NSLog("audioRecorderDidFinishRecording() -> \(flag)")
        
        guard let delegate = self.delegate else { return }
        
        delegate.recordingFinished()
    }
}