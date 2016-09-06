//
//  RecordedSoundFileDirectory.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 31/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class RecordedSoundFileDirectory {
    
    private var pathExtensionForRecordings: String
    
    let documentsDirectoryUrl: NSURL
    
    init(pathExtensionForRecordings: String) {
        self.pathExtensionForRecordings = pathExtensionForRecordings
        
        documentsDirectoryUrl =
            NSFileManager.defaultManager()
                .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                .first!
    }
    
    func deleteFile(url: NSURL) throws {
        try NSFileManager
            .defaultManager()
            .removeItemAtURL(url)
    }
}