//
//  AudioRecorder.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 31/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject { // for AVAudioRecorderDelegate :-(
    
    var audioRecorder: AVAudioRecorder!
    
    
    init(fileURL: NSURL) {
        
        super.init()
        
        let recordSettings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
            ]
        
        NSLog("AudioRecorder.init() with URL: \(fileURL.absoluteString)")
        
        do {
            audioRecorder = try AVAudioRecorder(URL: fileURL, settings: recordSettings as! [String : AnyObject])
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            NSLog("Error creating audioRecorder.")
        }
    }
    
    func start() {
        
        NSLog("AudioRecorder.start()")
        
        audioRecorder.record()
    }
    
    func stop() {
        
        NSLog("stop()")
        
        audioRecorder.stop()
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        
        NSLog("audioRecorderDidFinishRecording() -> \(flag)")
    }
}