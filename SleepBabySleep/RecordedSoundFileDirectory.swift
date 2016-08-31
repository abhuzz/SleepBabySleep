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
    
    
    func files() -> [NSURL]? {
        
        do {
            return
                try NSFileManager
                    .defaultManager()
                    .contentsOfDirectoryAtURL(documentsDirectoryUrl, includingPropertiesForKeys: nil, options: [])
                    .filter{ $0.pathExtension == pathExtensionForRecordings }
            
        } catch let exception as NSError {
            NSLog(exception.localizedDescription)
        }
        
        return nil
    }
}