//
//  UIColor+difference.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 04/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

extension UIColor {
    
    func getColorDifference(_ fromColor: UIColor) -> Int {
      
        // get the current color's red, green, blue and alpha values
        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        var alpha:CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // get the fromColor's red, green, blue and alpha values
        var fromRed:CGFloat = 0
        var fromGreen:CGFloat = 0
        var fromBlue:CGFloat = 0
        var fromAlpha:CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        let redValue = (max(red, fromRed) - min(red, fromRed)) * 255
        let greenValue = (max(green, fromGreen) - min(green, fromGreen)) * 255
        let blueValue = (max(blue, fromBlue) - min(blue, fromBlue)) * 255
        
        return Int(redValue + greenValue + blueValue)
    }
    
    func getBrightnessDifference(_ fromColor: UIColor) -> Int {
        
        // get the current color's red, green, blue and alpha values
        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        var alpha:CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let brightness = Int((((red * 299) + (green * 587) + (blue * 114)) * 255) / 1000)
        
        // get the fromColor's red, green, blue and alpha values
        var fromRed:CGFloat = 0
        var fromGreen:CGFloat = 0
        var fromBlue:CGFloat = 0
        var fromAlpha:CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        let fromBrightness = Int((((fromRed * 299) + (fromGreen * 587) + (fromBlue * 114)) * 255) / 1000)
        
        return max(brightness, fromBrightness) - min(brightness, fromBrightness)
    }
}
