//
//  UIViewController+showAlertDialog.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 08/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlertDialog(alertMessage: String ) {
        
        let dialog = UIAlertController(title: "SleepBabySleep", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        dialog.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(alert: UIAlertAction!) in return } ) )
        
        presentViewController(dialog, animated: false, completion: nil)
    }
}