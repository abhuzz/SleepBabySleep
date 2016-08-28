//
//  ViewController.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 17/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

enum PlayState {
    case Paused
    case Playing
}

class ViewController: UIViewController {
    
    private var backgroundAudioPlayer =
        TimedBackgroundAudioPlayer(audioPlayer: AVAudioPlayerFacade(), timer: SystemTimer(), appBundle: MainAppBundle())
    
    private var soundFiles =
        [SoundFile(Name: "Shhhhh", File: "Shhhh", Extension: "mp3"),
         SoundFile(Name: "Mhhhhh", File: "Mhhhh", Extension: "mp3"),
         SoundFile(Name: "Heia-Heia-Heia", File: "HeiaHeia", Extension: "mp3")]
    
    
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var soundFilePicker: UIPickerView!
    @IBOutlet weak var playbackDurationSegements: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundAudioPlayer.stateDelegate = self
        backgroundAudioPlayer.selectedSoundFile = soundFiles.first
        backgroundAudioPlayer.playbackDuration = PlaybackDuration(durationInMinutes: 5)
        
        soundFilePicker.delegate = self
        soundFilePicker.dataSource = self
    }
    
    
    @IBAction func actionTappedPlayPause(sender: AnyObject) {
        
        backgroundAudioPlayer.togglePlayState()
    }
    
    @IBAction func playbackDurationValueChanged(sender: AnyObject) {
    }
    
    func setGuiStateStartPlaying() {
        
        buttonPlayPause.setImage(UIImage(named: "Stop"), forState: .Normal)

    }
    
    func setGuiStateStopPlayback() {
        
        buttonPlayPause.setImage(UIImage(named: "Play"), forState: .Normal)
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
        
        backgroundAudioPlayer.selectedSoundFile = self.soundFiles[row]
    }
}

extension ViewController: BackgroundAudioPlayerStateDelegate {
    
    func playStateChanged(playState: PlayState) {
        
        switch playState {
        case .Playing:
                setGuiStateStartPlaying()
        case .Paused:
                setGuiStateStopPlayback()
        }
    }
}

