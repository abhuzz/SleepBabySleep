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
    
    private var backgroundAudioPlayer = TimedBackgroundAudioPlayer()
    private var soundFiles =
        [SoundFile(Name: "Shhhhh", File: "Shhhh"),
         SoundFile(Name: "Mhhhhh", File: "Mhhhh"),
         SoundFile(Name: "Heia-Heia-Heia", File: "HeiaHeia")]
    
    
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var soundFilePicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundAudioPlayer.stateDelegate = self
        backgroundAudioPlayer.selectedSoundFile = soundFiles.first
        
        soundFilePicker.delegate = self
        soundFilePicker.dataSource = self
    }
    
    
    @IBAction func actionTappedPlayPause(sender: AnyObject) {
        
        backgroundAudioPlayer.togglePlayState()
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
        
        if backgroundAudioPlayer.playState == .Playing {
            
            backgroundAudioPlayer.restartPlayingSound()
        }
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

