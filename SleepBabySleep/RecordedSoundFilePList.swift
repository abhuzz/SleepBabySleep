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
    private var format = NSPropertyListFormat.XMLFormat_v1_0
    private let pListUrl =
        NSFileManager.defaultManager()
            .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            .first!
            .URLByAppendingPathComponent("RecordedSoundFiles.plist")
    
    
    func recordedSoundFilesInPList() -> [SoundFile] {
        
        var soundFilesInPList = [SoundFile]()
        
        guard let plistData = NSData(contentsOfURL: pListUrl) else { return soundFilesInPList }
        
        do {
            let items =
                try NSPropertyListSerialization.propertyListWithData(plistData, options: .Immutable, format: &format) as! [AnyObject]
            
            soundFilesInPList =
                items.map { soundFile in
                    let lastPathComponent = soundFile["URL"]!! as! String
                    
                    let fileUrl =
                        RecordedSoundFileDirectory(pathExtensionForRecordings: "caf").documentsDirectoryUrl.URLByAppendingPathComponent(lastPathComponent)
                    
                    return RecordedAudioFile(identifier: NSUUID(UUIDString: soundFile["Identifier"]!! as! String)!,
                                                name: soundFile["Name"]!! as! String,
                                                url: fileUrl)
                    }
            
        } catch let error as NSError {
            NSLog("Error loading recordedSoundFilePList file: \(error.localizedDescription)")
        }
        
        return soundFilesInPList
    }
    
    func saveRecordedSoundFileToPlist(identifier: NSUUID, name: String, URL: NSURL) {
        
        do {
            var soundFilesDictionaries = try existingRecordDictionaries()
            
            soundFilesDictionaries.append(["Identifier": identifier.UUIDString, "Name": name, "URL": URL.lastPathComponent!])
            
            let serializedData =
                try NSPropertyListSerialization.dataWithPropertyList(soundFilesDictionaries, format: NSPropertyListFormat.XMLFormat_v1_0, options:0)
           
            serializedData.writeToURL(pListUrl, atomically: true)
            
        } catch let error as NSError {
            NSLog("Error saving recordedSoundFilePList file: \(error.localizedDescription)")
        }
    }
    
    private func existingRecordDictionaries() throws -> [[String: String]] {
        
        var soundFilesDictionaries = [[String: String]]()
        
        if let plistData = NSData(contentsOfURL: pListUrl) {
            
            let exitingEntries =
                try NSPropertyListSerialization.propertyListWithData(plistData, options: .Immutable, format: &format)
            
            soundFilesDictionaries.appendContentsOf(exitingEntries as! [[String: String]])
        }
     
        return soundFilesDictionaries
    }
}