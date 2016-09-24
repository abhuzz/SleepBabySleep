//
//  AssetImages.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 20/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit


protocol ImageState {
    func imageNumber() -> String
}

class AssetImageState: ImageState {
    
    private var currentState: Int
    private var imageCount: Int
    
    init(currentState: Int, imageCount: Int = 13) {
        self.currentState = currentState
        self.imageCount = imageCount
    }
    
    func imageNumber() -> String {
        
        var result: Int
        
        if currentState < imageCount {
            result = currentState
        }
        else if currentState % imageCount == 0 {
            result = imageCount
        }
        else {
            let value = currentState / imageCount
            let ignored = value * imageCount
            result = currentState - ignored
        }

        return String(result)
    }
}
