//
//  RecordingViewcontroller.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 07/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class RecordingViewcontroller: UIViewController {
    
    @IBOutlet weak var buttonRecording: UIButton!
    
    @IBAction func actionNavigationCancelled(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func recordingTouchDown(sender: AnyObject) {
        buttonRecording.setImage(UIImage(named: "Record_Active"), forState: .Normal)
        
        /*let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
         
         guard appDelegate.microphoneAvailable else {
            showAlertDialog("The microphone access for this app is disabled. Please enable it in the settings to record your sounds")
            return
         }
         
         if backgroundAudioPlayer!.playState == .Playing {
         backgroundAudioPlayer!.togglePlayState()
         }
         
         let newFileName = "\(NSUUID().UUIDString).\(recordingFileExtension)"
         let recordingFile = recordedSoundFileDirectory?.documentsDirectoryUrl.URLByAppendingPathComponent(newFileName)
         lastRecordedFileURL = recordingFile
         
         audioRecorder?.start(recordingFile!)*/

    
    }

    @IBAction func recordingTouchUp(sender: AnyObject) {
        buttonRecording.setImage(UIImage(named: "Record_Idle"), forState: .Normal)
    }
    
}
