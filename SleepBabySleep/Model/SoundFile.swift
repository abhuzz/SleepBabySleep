//
//  SoundFile.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 17/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import UIKit

protocol SoundFile {
    var Identifier: NSUUID { get }
    var Name: String { get }
    var URL: NSURL { get }
    var Image: UIImage { get }
    var Deletable: Bool { get }
}


struct AssetSoundFile: SoundFile, Equatable {
    
    private var fileName: String
    private var fileExtension: String
    private var image: UIImage
    
    init(Name: String, File: String, Extension:String) {
        self.Identifier = NSUUID()
        self.Name = Name
        self.fileName = File
        self.fileExtension = Extension
        self.image = imageForSound()
    }
    
    private(set) var Identifier: NSUUID
    private(set) var Name: String
    
    var URL: NSURL {
        get {
            return NSBundle
                    .mainBundle()
                    .URLForResource(fileName, withExtension: fileExtension)!
        }
    }
    
    var Image: UIImage {
        get { return image }
    }
    
    var Deletable: Bool {
        get { return false }
    }
}

func ==(lhs: AssetSoundFile, rhs: AssetSoundFile) -> Bool {
    return lhs.Name == rhs.Name
        && lhs.URL  == rhs.URL
}


struct RecordedAudioFile: SoundFile, Equatable{
    
    init(identifier: NSUUID, name: String, url: NSURL) {
        self.Identifier = identifier
        self.URL = url
        self.Name = name
        self.image = imageForSound()
    }

    private(set) var Identifier: NSUUID
    private(set) var Name: String
    private(set) var URL: NSURL
    private var image: UIImage
    
    var Image: UIImage {
        get { return image }
    }
    
    var Deletable: Bool {
        get { return true }
    }
}

func ==(lhs: RecordedAudioFile, rhs: RecordedAudioFile) -> Bool {
    return lhs.Name == rhs.Name
        && lhs.URL  == rhs.URL
}

var imageCount = 1

func imageForSound() -> UIImage {
    
    let name = "Tile_\(imageCount)"
    
    if imageCount <= 12 {
        imageCount += 1
    } else {
        imageCount = 1
    }
        
    guard let image = UIImage(named: name) else {
        NSLog("Image not found: \(name)")
        return UIImage()
    }
    
    return image

}
