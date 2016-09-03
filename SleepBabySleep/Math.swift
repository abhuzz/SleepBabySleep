//
//  Math.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 02/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import UIKit

func degreesToRadians(degrees: Double) -> CGFloat {
    return CGFloat(M_PI * (degrees) / 180.0)
}

func randomNumber(min: Int, max: Int) -> Int {
   
    var number = Int(arc4random_uniform(UInt32(max)))
    
    if number < min {
        number = min
    }
    
    return number
}