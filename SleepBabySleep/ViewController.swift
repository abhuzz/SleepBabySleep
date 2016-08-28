//
//  ViewController.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 17/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var timedBackgroundAudioPlayer: BackgroundAudioPlayer
    
    private var soundFiles =
        [SoundFile(Name: "Shhhhh", File: "Shhhh", Extension: "mp3"),
         SoundFile(Name: "Mhhhhh", File: "Mhhhh", Extension: "mp3"),
         SoundFile(Name: "Heia-Heia-Heia", File: "HeiaHeia", Extension: "mp3")]
    
    private var playbackDurationsBySegementIndex : [Int : PlaybackDuration] =
        [0 : PlaybackDurationMinutes(durationInMinutes: 5),
         1 : PlaybackDurationMinutes(durationInMinutes: 15),
         2 : PlaybackDurationMinutes(durationInMinutes: 30),
         3 : PlaybackDurationMinutes(durationInMinutes: 60),
         4 : PlaybackDurationMinutes(durationInMinutes: 90),
         5 : PlaybackDurationMinutes(durationInMinutes: 120),
         6 : PlaybackDurationInifinite()]
    
    
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var soundFilePicker: UIPickerView!
    @IBOutlet weak var playbackDurationSegements: UISegmentedControl!
    
    
    required init(coder aDecoder: NSCoder) {
        
        timedBackgroundAudioPlayer =
            TimedBackgroundAudioPlayer(
                audioPlayer: AVAudioPlayerFacade(),
                timer: SystemTimer(),
                appBundle: MainAppBundle())
        
        super.init(coder: aDecoder)!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        soundFilePicker.delegate = self
        soundFilePicker.dataSource = self
        
        timedBackgroundAudioPlayer.stateDelegate = self
        timedBackgroundAudioPlayer.selectedSoundFile = soundFiles.first
        timedBackgroundAudioPlayer.playbackDuration = playbackDurationsBySegementIndex[0]
    }
    
    
    @IBAction func actionTappedPlayPause(sender: AnyObject) {
        
        timedBackgroundAudioPlayer.togglePlayState()
    }
    
    @IBAction func playbackDurationValueChanged(sender: AnyObject) {
        
        let selectedSegmentIndex = playbackDurationSegements.selectedSegmentIndex
        
        guard let selectedPlaybackDuration = playbackDurationsBySegementIndex[selectedSegmentIndex] else { return }

        timedBackgroundAudioPlayer.playbackDuration = selectedPlaybackDuration
    }
}

extension ViewController: UIPickerViewDataSource {
   
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {

        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return soundFiles.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return soundFiles[row].Name
    }
}

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        timedBackgroundAudioPlayer.selectedSoundFile = self.soundFiles[row]
    }
}

extension ViewController: BackgroundAudioPlayerStateDelegate {
    
    func playStateChanged(playState: PlayState) {
        
        switch playState {
            
        case .Playing:
            buttonPlayPause.setImage(UIImage(named: "Stop"), forState: .Normal)
            
        case .Paused:
            buttonPlayPause.setImage(UIImage(named: "Play"), forState: .Normal)
        }
    }
}

