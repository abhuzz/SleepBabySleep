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

class RecordingViewController: UIViewController {
    
    private let recordingFileExtension = "caf"
    private let documentsDirectoryUrl =
            NSFileManager.defaultManager()
                .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                .first!
    private let temporaryDirectory = NSURL.fileURLWithPath(NSTemporaryDirectory())
    
    private var audioSession: AudioSession?
    private var audioRecorder: AudioRecorder?
    private var audioPlayer: AudioPlayer?
    private var lastRecordedFileURL: NSURL?
    private var playingPreview = false
    private var soundTimer: CFTimeInterval = 0.0
    private var updateTimer: CADisplayLink!
    
    var recordingDelegate: RecordingDelegate?
    
    
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    @IBOutlet weak var buttonPreview: UIButton!
    @IBOutlet weak var buttonRecording: UIButton!
    @IBOutlet weak var soundFileName: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    override func viewDidLoad() {
        
        audioSession = AVAudioSessionFacade()
        do {
            try audioSession?.openForRecording()
        } catch let error as NSError {
            NSLog("Failed opening audioSession for recording: \(error.localizedDescription)")
        }
        
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
    
    override func viewWillDisappear(animated: Bool) {
        do {
            try audioSession?.close()
        } catch let error as NSError {
            NSLog("Failed to close audioSession: \(error.localizedDescription)")
        }
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
        
        guard let audioSession = self.audioSession else { return }
    
        guard audioSession.microphoneAvailble() else {
            showAlertDialog("The microphone access for this app is disabled. Please enable it in the settings to record your sounds")
            return
        }
        
        buttonRecording.setImage(UIImage(named: "Record_Active"), forState: .Normal)
        
        deleteTemporaryRecordingFile()
        
        let newFileName = "\(NSUUID().UUIDString).\(recordingFileExtension)"
        lastRecordedFileURL = temporaryDirectory.URLByAppendingPathComponent(newFileName)
         
        audioRecorder?.start(lastRecordedFileURL!)
        startUpdateLoop()
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
    
    func startUpdateLoop() {
        
        if updateTimer != nil {
            updateTimer.invalidate()
        }
        
        updateTimer = CADisplayLink(target: self, selector: #selector(RecordingViewController.updateLoop))
        updateTimer.frameInterval = 1
        updateTimer.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func stopUpdateLoop() {
        
        updateTimer.invalidate()
        updateTimer = nil
    }
    
    func updateLoop() {
        
        if CFAbsoluteTimeGetCurrent() - soundTimer > 0.5 {
            durationLabel.text = formattedCurrentTime(UInt(audioRecorder!.currentTime))
            soundTimer = CFAbsoluteTimeGetCurrent()
        }
    }
    
    func formattedCurrentTime(time: UInt) -> String {
        
        let hours = time / 3600
        let minutes = (time / 60) % 60
        let seconds = time % 60
        
        return String(format: "%02i:%02i:%02i", arguments: [hours, minutes, seconds])
    }
}

extension RecordingViewController: AudioRecorderDelegate {
    
    func recordingFinished() {
        
        stopUpdateLoop()
        
        guard lastRecordedFileURL != nil else { return }
        
        buttonPreview.enabled = true
        
        updateSaveIsPossibleState()
    }
}

extension RecordingViewController: AudioPlayerStateDelegate {

    func playbackCancelled() {
        
        playPreviewStopped()
    }
    
    func playbackStopped() {
        
        playPreviewStopped()
    }
}
