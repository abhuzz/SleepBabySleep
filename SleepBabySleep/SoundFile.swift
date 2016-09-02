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
    var Name: String { get }
    var URL: NSURL { get }
    var Image: UIImage { get }
}


struct AssetSoundFile: SoundFile, Equatable {
    
    private var fileName: String
    private var fileExtension: String
    
    init(Name: String, File: String, Extension:String) {
        self.Name = Name
        self.fileName = File
        self.fileExtension = Extension
    }
    
    private(set) var Name: String
    
    var URL: NSURL {
        get {
            return NSBundle
                    .mainBundle()
                    .URLForResource(fileName, withExtension: fileExtension)!
        }
    }
    
    var Image: UIImage {
        get {
            return UIImage(named: "Item_1")!
        }
    }
}

func ==(lhs: AssetSoundFile, rhs: AssetSoundFile) -> Bool {
    return lhs.Name == rhs.Name
        && lhs.URL  == rhs.URL
}


struct RecordedAudioFile: SoundFile, Equatable{
    
    init(url: NSURL) {
        self.URL = url
        self.Name = url.lastPathComponent ?? "n/a"
    }

    private(set) var Name: String
    private(set) var URL: NSURL
    
    var Image: UIImage {
        get {
            return UIImage(named: "Item_1")!
        }
    }
}

func ==(lhs: RecordedAudioFile, rhs: RecordedAudioFile) -> Bool {
    return lhs.Name == rhs.Name
        && lhs.URL  == rhs.URL
}
