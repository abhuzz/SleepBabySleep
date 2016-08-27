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

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var backgroundAudioPlayer = BackgroundAudioPlayer()
    
    var soundFiles =
        [SoundFile(Name: "Shhhhh", File: "Shhhh"),
         SoundFile(Name: "Mhhhhh", File: "Mhhhh"),
         SoundFile(Name: "Heia-Heia-Heia", File: "HeiaHeia")]
    
    
    
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var soundFilePicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundAudioPlayer.stateDelegate = self
        backgroundAudioPlayer.selectedSoundFile = soundFiles.first
        
        self.soundFilePicker.delegate = self
        self.soundFilePicker.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    @IBAction func actionTappedPlayPause(sender: AnyObject) {
        
        backgroundAudioPlayer.togglePlayState()
    }
    
    
    // MARK: UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.soundFiles.count
    }
 
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.soundFiles[row].Name
    }
    
    
    // MARK: UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        backgroundAudioPlayer.selectedSoundFile = self.soundFiles[row]
        
        if backgroundAudioPlayer.playState == .Playing {
            
            backgroundAudioPlayer.restartPlayingSound()
        }
    }
    
    
    // MARK: Helper Methods
        
    func setGuiStateStartPlaying() {
        
        self.buttonPlayPause.setImage(UIImage(named: "Stop"), forState: .Normal)

    }
    
    func setGuiStateStopPlayback() {
        
        self.buttonPlayPause.setImage(UIImage(named: "Play"), forState: .Normal)
    }
    
}

extension ViewController: BackgroundAudioPlayerStateDelegate {
    
    func playStateChanged(playState: PlayState) {
        
        if playState == .Paused {
            
            setGuiStateStopPlayback()
        } else {
            
            setGuiStateStartPlaying()
        }
    }
}

