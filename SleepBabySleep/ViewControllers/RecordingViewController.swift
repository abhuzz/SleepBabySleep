//
//  RecordingViewcontroller.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 07/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

protocol RecordingDelegate {
    
    func recordingAdded(uuid: UUID)
}

class RecordingViewController: UIViewController {
    
    private let recordingFileExtension = "caf"
    private let documentsDirectoryUrl =
            FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
    private let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
    
    private var audioSession: AudioSession?
    private var audioRecorder: AudioRecorder?
    private var audioPlayer: AudioPlayer?
    private var imageNumberState = ImageNumberState()
    fileprivate var lastRecordedFileURL: URL?
    private var playingPreview = false
    private var soundTimer: CFTimeInterval = 0.0
    private var updateTimer: CADisplayLink?
    
    var recordingDelegate: RecordingDelegate?
    
    
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    @IBOutlet weak var buttonPreview: UIButton!
    @IBOutlet weak var buttonRecording: UIButton!
    @IBOutlet weak var soundFileName: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    override func viewDidLoad() {
        
        do {
            audioSession = AVAudioSessionFacade()
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        if lastRecordedFileURL == nil {
            buttonPreview.isEnabled = false
        }
        
        updateSaveIsPossibleState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        do {
            try audioSession?.close()
        } catch let error as NSError {
            NSLog("Failed to close audioSession: \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func actionNavigationCancelled(_ sender: AnyObject) {
        
        stopPlayingPreview()
        deleteTemporaryRecordingFile()
        
        navigateToMainView()
    }
    
    @IBAction func actionNavigationSave(_ sender: AnyObject) {
        
        do {
            
            let newRecordingUUID = UUID()
            
            stopPlayingPreview()
            
            try saveRecording(uuid: newRecordingUUID)
            
            if let delegate = self.recordingDelegate {
                delegate.recordingAdded(uuid: newRecordingUUID)
            }
            
            navigateToMainView()
        
        } catch let error as NSError {
            showAlertDialog(error.localizedDescription)
        }
    }
    
    @IBAction func actionTextFieldChanged(_ sender: AnyObject) {
        
        updateSaveIsPossibleState()
    }

    @IBAction func actionPreviewTapped(_ sender: AnyObject) {
        
        if playingPreview {
            stopPlayingPreview()
        } else {
            startPlayingPreview()
        }
    }
    
    @IBAction func recordingTouchDown(_ sender: AnyObject) {
        
        guard let audioSession = self.audioSession else { return }
    
        guard audioSession.microphoneAvailble() else {
            showAlertDialog(
                    NSLocalizedString("The microphone access for this app is disabled. Please enable it in the settings to record your sounds", comment: "Error - mircophone access not possible")
                )
            return
        }
    
        buttonRecording.setImage(UIImage(named: "Record_Active"), for: UIControlState())
        
        deleteTemporaryRecordingFile()
        
        let newFileName = "\(UUID().uuidString).\(recordingFileExtension)"
        lastRecordedFileURL = temporaryDirectory.appendingPathComponent(newFileName)
         
        audioRecorder?.start(lastRecordedFileURL!)
        startUpdateLoop()
    }

    @IBAction func recordingTouchUp(_ sender: AnyObject) {
        
        buttonRecording.setImage(UIImage(named: "Record_Idle"), for: UIControlState())
        
        audioRecorder?.stop()
    }
    
    fileprivate func updateSaveIsPossibleState() {
        
        if lastRecordedFileURL == nil || soundFileName.text?.characters.count == 0 {
            buttonSave.isEnabled = false
        } else {
            buttonSave.isEnabled = true
        }
    }
    
    private func startPlayingPreview() {
        
        guard let previewSoundFile = lastRecordedFileURL else { return }
        
        playingPreview = true
        buttonPreview.setImage(UIImage(named: "Stop"), for: UIControlState())
        
        audioPlayer?.play(previewSoundFile)
    }
    
    private func stopPlayingPreview() {
        
        audioPlayer?.stop()
    }
    
    fileprivate func playPreviewStopped() {
        
        playingPreview = false
        buttonPreview.setImage(UIImage(named: "Play"), for: UIControlState())
    }
    
    private func saveRecording(uuid: UUID) throws {
        
        guard let recordingURL = lastRecordedFileURL else { return }
        
        let targetURL =
            documentsDirectoryUrl.appendingPathComponent(recordingURL.lastPathComponent)
        
        try FileManager.default
            .moveItem(at: recordingURL, to: targetURL)
            
        try RecordedSoundFilesPList()
            .saveRecordedSoundFileToPlist(uuid, name: soundFileName.text!, URL: recordingURL, imageName: "Tile_\(imageNumberState.nextImageNumber().imageNumber())")
    }
    
    private func deleteTemporaryRecordingFile() {
        
        guard let fileUrl = lastRecordedFileURL else { return }
        
        DispatchQueue.global().async {
            
            do {
                try FileManager.default.removeItem(at: fileUrl)
                NSLog("Deleted temporary file: \(fileUrl.lastPathComponent)")
            } catch let error as NSError {
                NSLog("Failed to delete a temorary recording: \(error.localizedDescription)")
            }
        }
    }
    
    private func navigateToMainView() {
        
        navigationController?.setNavigationBarHidden(true, animated: true)
     
        _ = navigationController?.popViewController(animated: true)
    }
    
    func startUpdateLoop() {
        
        updateTimer?.invalidate()
        
        updateTimer = CADisplayLink(target: self, selector: #selector(RecordingViewController.updateLoop))
        updateTimer!.preferredFramesPerSecond = 2
        updateTimer!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    func stopUpdateLoop() {
        
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func updateLoop() {
        
        if CFAbsoluteTimeGetCurrent() - soundTimer > 0.5 {
            durationLabel.text = formattedCurrentTime(UInt(audioRecorder!.currentTime))
            soundTimer = CFAbsoluteTimeGetCurrent()
        }
    }
    
    func formattedCurrentTime(_ time: UInt) -> String {
        
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
        
        buttonPreview.isEnabled = true
        
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
