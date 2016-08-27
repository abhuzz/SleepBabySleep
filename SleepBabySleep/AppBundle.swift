//
//  AppBundle.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

protocol AppBundle {
    func file(withName: String, andExtension: String) -> NSURL
}

class MainAppBundle: AppBundle {
    
    func file(withName: String, andExtension: String) -> NSURL {
        return NSBundle.mainBundle().URLForResource(withName, withExtension: andExtension)!
    }
}