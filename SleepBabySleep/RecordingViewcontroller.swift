//
//  RecordingViewcontroller.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 07/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class RecordingViewcontroller: UIViewController {
    
    private let recordingFileExtension = "caf"
    private let documentsDirectoryUrl =
            NSFileManager.defaultManager()
                .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                .first!
    
    private var audioRecorder: AudioRecorder?
    private var lastRecordedFileURL: NSURL?
    
    @IBOutlet weak var buttonRecording: UIButton!
    @IBOutlet weak var soundFileName: UITextField!
    
    
    override func viewDidLoad() {
        
        audioRecorder = AudioRecorder()
        audioRecorder?.delegate = self
        
    }
    
    
    @IBAction func actionNavigationCancelled(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func recordingTouchDown(sender: AnyObject) {
        buttonRecording.setImage(UIImage(named: "Record_Active"), forState: .Normal)
        
        let newFileName = "\(NSUUID().UUIDString).\(recordingFileExtension)"
        let recordingFile = documentsDirectoryUrl.URLByAppendingPathComponent(newFileName)
        lastRecordedFileURL = recordingFile
         
        audioRecorder?.start(recordingFile)
    }

    @IBAction func recordingTouchUp(sender: AnyObject) {
        buttonRecording.setImage(UIImage(named: "Record_Idle"), forState: .Normal)
        
        audioRecorder?.stop()
    }
    
}

extension RecordingViewcontroller: AudioRecorderDelegate {
    
    func recordingFinished() {
        
        guard let recordingURL = lastRecordedFileURL else { return }
        
        do {
            try RecordedSoundFilesPList().saveRecordedSoundFileToPlist(NSUUID(), name: soundFileName.text!, URL: recordingURL)
        } catch let error as NSError {
            showAlertDialog(error.localizedDescription)
        }
    }
}
