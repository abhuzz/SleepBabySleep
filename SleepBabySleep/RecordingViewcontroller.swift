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
    private var playingPreview = false
    
    internal var recordingDelegate: RecordingDelegate?
    
    
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    @IBOutlet weak var buttonPreview: UIButton!
    @IBOutlet weak var buttonRecording: UIButton!
    @IBOutlet weak var soundFileName: UITextField!
    
    
    override func viewDidLoad() {
        
        audioRecorder = AudioRecorder()
        audioRecorder?.delegate = self
        
        audioPlayer = AVAudioPlayerFacade(numberOfLoops: 0)
        audioPlayer?.stateDelegate = self
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if lastRecordedFileURL == nil {
            buttonPreview.enabled = false
        }
        
        updateSaveIsPossibleState()
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
    
    @IBAction func actionTextFieldChanged(sender: AnyObject) {
        
        updateSaveIsPossibleState()
    }

    
    @IBAction func actionPreviewTapped(sender: AnyObject) {
        
        if playingPreview {
            stopPlayingPreview()
        } else {
            startPlayingPreview()
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
    
    private func updateSaveIsPossibleState() {
        
        if lastRecordedFileURL == nil || soundFileName.text?.characters.count == 0 {
            buttonSave.enabled = false
        } else {
            buttonSave.enabled = true
        }
    }
    
    private func startPlayingPreview() {
        
        guard let previewSoundFile = lastRecordedFileURL else { return }
        
        playingPreview = true
        buttonPreview.setImage(UIImage(named: "Stop"), forState: .Normal)
        
        audioPlayer?.play(previewSoundFile)
    }
    
    private func stopPlayingPreview() {
        
        audioPlayer?.stop()
    }
    
    private func playPreviewStopped() {
        
        playingPreview = false
        buttonPreview.setImage(UIImage(named: "Play"), forState: .Normal)
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
        
        guard lastRecordedFileURL != nil else { return }
        
        buttonPreview.enabled = true
        
        updateSaveIsPossibleState()
    }
}

extension RecordingViewcontroller: AudioPlayerStateDelegate {

    func playbackCancelled() {
        
        playPreviewStopped()
    }
    
    func playbackStopped() {
        
        playPreviewStopped()
    }
}
