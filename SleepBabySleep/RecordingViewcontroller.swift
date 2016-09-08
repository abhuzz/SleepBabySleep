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
    
    @IBAction func recordingTouchUp(sender: AnyObject) {
        buttonRecording.setImage(UIImage(named: "Record_Idle"), forState: .Normal)
    }
    
    @IBAction func recordingTouchDown(sender: AnyObject) {
        buttonRecording.setImage(UIImage(named: "Record_Active"), forState: .Normal)
    }
    
}