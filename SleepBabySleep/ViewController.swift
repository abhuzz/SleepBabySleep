//
//  ViewController.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 17/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

enum PlayState {
    case Paused
    case Playing
}

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var player: AVAudioPlayer?
    var playState: PlayState = .Paused
    var soundFiles =
        [SoundFile(Name: "Shhhhh", File: "Shhhh"),
         SoundFile(Name: "Mhhhhh", File: "Mhhhh"),
         SoundFile(Name: "Heia-Heia-Heia", File: "HeiaHeia")]

    
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var soundFilePicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeBackgroundAudioPlayback()
        
        self.soundFilePicker.delegate = self
        self.soundFilePicker.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    @IBAction func actionTappedPlayPause(sender: AnyObject) {
        
        if self.playState == .Paused {
            startPlayingSound()
            self.buttonPlayPause.setImage(UIImage(named: "Stop"), forState: .Normal)
            self.playState = .Playing
        } else {
            stopPLayingSound()
            self.buttonPlayPause.setImage(UIImage(named: "Play"), forState: .Normal)
            self.playState = .Paused
        }
        
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
        
    }
    
    
    // MARK: Helper Methods
    func initializeBackgroundAudioPlayback() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                NSLog("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                NSLog("AVAudioSession is Active")
            } catch let error as NSError {
                NSLog(error.localizedDescription)
            }
        } catch let error as NSError {
            NSLog(error.localizedDescription)
        }

    }
    
    func startPlayingSound() {
        let url = NSBundle.mainBundle().URLForResource("Shhhh", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOfURL: url)
            
            guard let player = player else { return }
            
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func stopPLayingSound() {
        
        guard let player = self.player else { return }
        
        player.pause()
    }
}

