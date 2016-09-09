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
    private var audioPlayer: AudioPlayer?
    private var lastRecordedFileURL: NSURL?
    
    internal var recordingDelegate: RecordingDelegate?
    
    
    @IBOutlet weak var buttonRecording: UIButton!
    @IBOutlet weak var soundFileName: UITextField!
    
    
    override func viewDidLoad() {
        
        audioRecorder = AudioRecorder()
        audioRecorder?.delegate = self
        
        audioPlayer = AVAudioPlayerFacade(numberOfLoops: 1)
        audioPlayer?.stateDelegate = self
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    @IBAction func actionNavigationCancelled(sender: AnyObject) {
        
        deleteTemporaryRecordingFile()
        
        navigateToMainView()
    }
    
    @IBAction func actionNavigationSave(sender: AnyObject) {
        
        do {
            
            try saveRecording()
            
            if let delegate = self.recordingDelegate {
                delegate.recordingAdded()
            }
            
            navigateToMainView()
        
        } catch let error as NSError {
            showAlertDialog(error.localizedDescription)
        }
    }
    
    @IBAction func recordingTouchDown(sender: AnyObject) {
        
        buttonRecording.setImage(UIImage(named: "Record_Active"), forState: .Normal)
        
        deleteTemporaryRecordingFile()
        
        let newFileName = "\(NSUUID().UUIDString).\(recordingFileExtension)"
        lastRecordedFileURL = temporaryDirectory.URLByAppendingPathComponent(newFileName)
         
        audioRecorder?.start(lastRecordedFileURL!)
    }

    @IBAction func recordingTouchUp(sender: AnyObject) {
        
        buttonRecording.setImage(UIImage(named: "Record_Idle"), forState: .Normal)
        
        audioRecorder?.stop()
    }
    
    private func saveRecording() throws {
        
        guard let recordingURL = lastRecordedFileURL else { return }
        
        let targetURL =
            documentsDirectoryUrl.URLByAppendingPathComponent(recordingURL.lastPathComponent!)
        
        try NSFileManager.defaultManager()
            .moveItemAtURL(recordingURL, toURL: targetURL)
            
        try RecordedSoundFilesPList()
            .saveRecordedSoundFileToPlist(NSUUID(), name: soundFileName.text!, URL: recordingURL)
    }
    
    private func deleteTemporaryRecordingFile() {
        
        guard let fileUrl = lastRecordedFileURL else { return }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            do {
                try NSFileManager.defaultManager().removeItemAtURL(fileUrl)
                NSLog("Deleted temporary file: \(fileUrl.lastPathComponent!)")
            } catch let error as NSError {
                NSLog("Failed to delete a temorary recording: \(error.localizedDescription)")
            }
        }
    }
    
    private func navigateToMainView() {
        
        navigationController?.setNavigationBarHidden(true, animated: true)
     
        navigationController?.popViewControllerAnimated(true)
    }
}

extension RecordingViewcontroller: AudioRecorderDelegate {
    
    func recordingFinished() {
        
        // Enable previe
    }
}

extension RecordingViewcontroller: AudioPlayerStateDelegate {

    func playbackCancelled() {
        
    }
    
    func playbackStopped() {
        
    }
}
