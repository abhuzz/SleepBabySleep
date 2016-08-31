//
//  SoundFile.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 17/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

struct SoundFile: Equatable {
    
    var Name: String
    var File: String
    var Extension: String
    
    var temporaryURL: NSURL?
    
    init(temporaryURL: NSURL) {
        self.Name = "Recording"
        self.temporaryURL = temporaryURL
        self.File = ""
        self.Extension = ""
    }
    
    init(Name: String, File: String, Extension:String) {
        self.Name = Name
        self.File = File
        self.Extension = Extension
    }
}

func ==(lhs: SoundFile, rhs: SoundFile) -> Bool {
    return     lhs.Name == rhs.Name
            && lhs.File == rhs.File
            && lhs.Extension == rhs.Extension
}
