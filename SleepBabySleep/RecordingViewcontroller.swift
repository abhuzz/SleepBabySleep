//
//  RecordingViewcontroller.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 07/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

protocol RecordingDelegate {
    
    func recordingAdded()
}

class RecordingViewcontroller: UIViewController {
    
    private let recordingFileExtension = "caf"
    private let documentsDirectoryUrl =
            NSFileManager.defaultManager()
                .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                .first!
    private let temporaryDirectory = NSURL.fileURLWithPath(NSTemporaryDirectory())
    
    private var audioRecorder: AudioRecorder?
    private var lastRecordedFileURL: NSURL?
    
    public var recordingDelegate: RecordingDelegate?
    
    
    @IBOutlet weak var buttonRecording: UIButton!
    @IBOutlet weak var soundFileName: UITextField!
    
    
    override func viewDidLoad() {
        
        audioRecorder = AudioRecorder()
        audioRecorder?.delegate = self
    }
    
    
    @IBAction func actionNavigationCancelled(sender: AnyObject) {
          
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func actionNavigationSave(sender: AnyObject) {
        
        do {
            
            try saveRecording()
            
            if let delegate = self.recordingDelegate {
                delegate.recordingAdded()
            }
            
            navigationController?.popViewControllerAnimated(true)
        
        } catch let error as NSError {
            showAlertDialog(error.localizedDescription)
        }
    }
    
    @IBAction func recordingTouchDown(sender: AnyObject) {
        
        buttonRecording.setImage(UIImage(named: "Record_Active"), forState: .Normal)
        
        let newFileName = "\(NSUUID().UUIDString).\(recordingFileExtension)"
        
        lastRecordedFileURL = temporaryDirectory.URLByAppendingPathComponent(newFileName)
         
        audioRecorder?.start(lastRecordedFileURL!)
    }

    @IBAction func recordingTouchUp(sender: AnyObject) {
        
        buttonRecording.setImage(UIImage(named: "Record_Idle"), forState: .Normal)
        
        audioRecorder?.stop()
    }
    
    func saveRecording() throws {
        
        guard let recordingURL = lastRecordedFileURL else { return }
        
        let targetURL =
            documentsDirectoryUrl.URLByAppendingPathComponent(recordingURL.lastPathComponent!)
        
        try NSFileManager.defaultManager()
            .moveItemAtURL(recordingURL, toURL: targetURL)
            
        try RecordedSoundFilesPList()
            .saveRecordedSoundFileToPlist(NSUUID(), name: soundFileName.text!, URL: recordingURL)
    }
}

extension RecordingViewcontroller: AudioRecorderDelegate {
    
    func recordingFinished() {
        
        
    }
}
