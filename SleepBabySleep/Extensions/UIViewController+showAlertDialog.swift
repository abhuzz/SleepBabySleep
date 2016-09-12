//
//  UIViewController+showAlertDialog.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 08/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlertDialog(_ alertMessage: String ) {
        
        let dialog = UIAlertController(title: "SleepBabySleep", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in return } ) )
        
        present(dialog, animated: false, completion: nil)
    }
}
