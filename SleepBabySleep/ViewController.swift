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

class ViewController: UIViewController {
    
    var player: AVAudioPlayer?
    var playState: PlayState = .Paused
    var soundFiles =
        [SoundFile(Name: "Shhhhh", File: "Shhhh"),
         SoundFile(Name: "Mhhhhh", File: "Mhhhh"),
         SoundFile(Name: "Heia-Heia-Heia", File: "HeiaHeia")]

    @IBOutlet weak var buttonPlayPause: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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

