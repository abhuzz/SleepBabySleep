//
//  ViewController.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 17/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {
    
    private let recordingFileExtension = "caf"
    
    private var backgroundAudioPlayer: BackgroundAudioPlayer?
    private var audioRecorder: AudioRecorder?
    
    private var recordedSoundFileDirectory: RecordedSoundFileDirectory?
    private var playList: SoundFilePlaylist?
    
    private var playbackDurationsBySegementIndex : [Int : PlaybackDuration] =
        [0 : PlaybackDurationMinutes(durationInMinutes: 5),
         1 : PlaybackDurationMinutes(durationInMinutes: 15),
         2 : PlaybackDurationMinutes(durationInMinutes: 30),
         3 : PlaybackDurationMinutes(durationInMinutes: 60),
         4 : PlaybackDurationMinutes(durationInMinutes: 90),
         5 : PlaybackDurationMinutes(durationInMinutes: 120),
         6 : PlaybackDurationInifinite()]
    
    
    @IBOutlet weak var soundFilePicker: UIPickerView!
    @IBOutlet weak var playbackDurationSegements: UISegmentedControl!
    @IBOutlet weak var buttonPlayPause: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        soundFilePicker.delegate = self
        soundFilePicker.dataSource = self
        
        recordedSoundFileDirectory =
            RecordedSoundFileDirectory(pathExtensionForRecordings: recordingFileExtension)
        
        playList =
            SoundFilePlaylist(soundFiles: availableSoundFiles())
    
        audioRecorder = AudioRecorder()
        audioRecorder?.delegate = self
        
        backgroundAudioPlayer =
            TimedBackgroundAudioPlayer(
                audioPlayer: AVAudioPlayerFacade(),
                timer: SystemTimer())
        
        backgroundAudioPlayer!.stateDelegate = self
        backgroundAudioPlayer!.selectedSoundFile = playList!.first()
        backgroundAudioPlayer!.playbackDuration = playbackDurationsBySegementIndex[0]
        
        
        initRemoteCommands()
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        updateSoundFilePickerSelectionFromPlaylist()
    }
    
    
    @IBAction func actionTappedPlayPause(sender: AnyObject) {
        
        backgroundAudioPlayer!.togglePlayState()
    }
    
    @IBAction func actionTappedPrevious(sender: AnyObject) {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.previous()
    }
    
    @IBAction func actionTappedNext(sender: AnyObject) {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.next()
    }
    
    @IBAction func playbackDurationValueChanged(sender: AnyObject) {
        
        let selectedSegmentIndex = playbackDurationSegements.selectedSegmentIndex
        
        guard let selectedPlaybackDuration = playbackDurationsBySegementIndex[selectedSegmentIndex] else { return }

        backgroundAudioPlayer!.playbackDuration = selectedPlaybackDuration
    }
    
    @IBAction func recordTouchDown(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        guard appDelegate.microphoneAvailable else {
            showAlerDialog("The microphone access for this app is disabled. Please enable it in the settings to record your sounds")
            return
        }
        
        if backgroundAudioPlayer!.playState == .Playing {
            backgroundAudioPlayer!.togglePlayState()
        }
        
        let newFileName = "\(NSUUID().UUIDString).\(recordingFileExtension)"
        let recordingFile = recordedSoundFileDirectory?.documentsDirectoryUrl.URLByAppendingPathComponent(newFileName)

        audioRecorder?.start(recordingFile!)
    }
    
    @IBAction func recordTouchUp(sender: AnyObject) {
        audioRecorder?.stop()
    }
    
    
    func updateSoundFilePickerSelectionFromPlaylist() {
        
        if soundFilePicker.selectedRowInComponent(0) != playList!.index {
            soundFilePicker.selectRow(playList!.index, inComponent: 0, animated: true)
        }
    }
    
    func showAlerDialog(alertMessage: String ) {
        
        let dialog = UIAlertController(title: "SleepBabySleep", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(alert: UIAlertAction!) in return } ) )
        presentViewController(dialog, animated: false, completion: nil)
    }
    
    func availableSoundFiles() -> [SoundFile] {
        
        var soundFiles = [SoundFile]()
        
        let assetSoundFiles =
                [AssetSoundFile(Name: "Shhhhh", File: "Shhhh", Extension: "mp3"),
                 AssetSoundFile(Name: "Mhhhhh", File: "Mhhhh", Extension: "mp3"),
                 AssetSoundFile(Name: "Heia-Heia-Heia", File: "HeiaHeia", Extension: "mp3"),
                 AssetSoundFile(Name: "Vacuum cleaner", File: "VacuumCleaner", Extension: "mp3")]
        
        soundFiles.appendContentsOf(
            assetSoundFiles.map { assetSoundFile in
                assetSoundFile as SoundFile
            })
        
        if let recordedSounds = recordedSoundFileDirectory!.files() {
            let recordedSoundFiles =
                recordedSounds.map { url in
                    RecordedAudioFile(url: url) as SoundFile
                }
            
            soundFiles.appendContentsOf(recordedSoundFiles)
        }
        
        return soundFiles
    }
}

extension ViewController: UIPickerViewDataSource {
   
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {

        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return playList!.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return playList!.nameForRow(row)
    }
}

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.jumptoRow(row)
    }
}

extension ViewController: BackgroundAudioPlayerStateDelegate {
    
    func playStateChanged(playState: PlayState) {
        
        switch playState {
            
        case .Playing:
            updateTrackInfoInRemoteCommandCenter()
            buttonPlayPause.setImage(UIImage(named: "Stop"), forState: .Normal)
            updateSoundFilePickerSelectionFromPlaylist()
            
        case .Paused:
            buttonPlayPause.setImage(UIImage(named: "Play"), forState: .Normal)
        }
    }
}

extension ViewController: AudioRecorderDelegate {
    
    func recordingFinished() {
        
        playList = SoundFilePlaylist(soundFiles: availableSoundFiles())
        soundFilePicker.reloadComponent(0)
        updateSoundFilePickerSelectionFromPlaylist()
    }
}

extension ViewController { // MPRemoteCommands

    func initRemoteCommands() {
        
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        
        commandCenter.playCommand.enabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(ViewController.PlayPauseCommand))
        
        commandCenter.pauseCommand.enabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(ViewController.PlayPauseCommand))
        
        commandCenter.nextTrackCommand.enabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(ViewController.nextTrackCommand))
        
        commandCenter.previousTrackCommand.enabled = true
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(ViewController.previousTrackCommand))
        
    }
    
    func updateTrackInfoInRemoteCommandCenter() {
        
        let nowPlayingCenter = MPNowPlayingInfoCenter.defaultCenter()
        
        nowPlayingCenter.nowPlayingInfo =
            [MPMediaItemPropertyTitle: backgroundAudioPlayer!.selectedSoundFile!.Name,
             MPMediaItemPropertyAlbumTitle: "Baby sleep",
             MPMediaItemPropertyAlbumTrackCount: NSNumber(int: Int32(playList!.count)),
             MPMediaItemPropertyAlbumTrackNumber: NSNumber(int: Int32(playList!.number)),
             MPMediaItemPropertyPlaybackDuration: NSNumber(float: Float(backgroundAudioPlayer!.playbackDuration!.totalSeconds()))]
    }
    
    func PlayPauseCommand() {
        
        backgroundAudioPlayer!.togglePlayState()
    }
    
    func nextTrackCommand() {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.next()
    }
    
    func previousTrackCommand() {
        
        backgroundAudioPlayer!.selectedSoundFile = playList!.previous()
    }
}


