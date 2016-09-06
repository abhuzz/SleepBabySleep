//
//  Recoe.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 06/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class RecordedSoundFilesPList {
    
    private let fileManager = NSFileManager.defaultManager()

    private let pListUrl =
        NSFileManager.defaultManager()
            .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            .first!
            .URLByAppendingPathComponent("RecordedSoundFiles.plist")
    
    
    func recordedSoundFilesInPList() -> [SoundFile] {
        
        var soundFilesInPList = [SoundFile]()
        
        var format = NSPropertyListFormat.XMLFormat_v1_0
        
        guard let plistData = NSData(contentsOfURL: pListUrl) else { return soundFilesInPList }
        
        do {
            let items =
                try NSPropertyListSerialization.propertyListWithData(plistData, options: .Immutable, format: &format) as! [AnyObject]
            
            soundFilesInPList =
                items.map { soundFile in
                    return RecordedAudioFile(name: soundFile["Name"]!! as! String, url: NSURL(fileURLWithPath: soundFile["URL"]!! as! String))
            }
            
        } catch let error as NSError {
            NSLog("Error loading recordedSoundFilePList file: \(error.localizedDescription)")
        }
        
        return soundFilesInPList
    }
    
    func saveRecordedSoundFileToPlist(name: String, URL: NSURL) {
        
        var format = NSPropertyListFormat.XMLFormat_v1_0
        
        do {
            var soundFilesDictionaries = [[String: NSObject]]()
            
            if let plistData = NSData(contentsOfURL: pListUrl) {
             
                let exitingEntries =
                    try NSPropertyListSerialization.propertyListWithData(plistData, options: .Immutable, format: &format)
                
                soundFilesDictionaries.append(exitingEntries as! [String: String])
            }
                
            soundFilesDictionaries.append(["Name": name, "URL": URL.absoluteString])
            
            
            let serializedData =
                try NSPropertyListSerialization.dataWithPropertyList(soundFilesDictionaries, format: NSPropertyListFormat.XMLFormat_v1_0, options:0)
           
            serializedData.writeToURL(pListUrl, atomically: true)
            
        } catch let error as NSError {
            NSLog("Error saving recordedSoundFilePList file: \(error.localizedDescription)")
        }
    }
    
    private func pListFileExists() -> Bool {
        return fileManager.fileExistsAtPath(pListUrl.absoluteString)
    }
}