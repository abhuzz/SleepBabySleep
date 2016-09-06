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
    private let documentsDirectory: NSURL
    private let pListUrl: NSURL
    
    
    init() {
        
        documentsDirectory =
            NSFileManager.defaultManager()
                .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                .first!
        
        pListUrl =
            documentsDirectory
                .URLByAppendingPathComponent("RecordedSoundFiles.plist")
    }
    
    
    func recordedSoundFilesInPList() -> [SoundFile] {
        
        guard let plistData = NSData(contentsOfURL: pListUrl) else { return [SoundFile]() }
        
        do {
            let items =
                try NSPropertyListSerialization.propertyListWithData(plistData, options: .Immutable, format: &format) as! [AnyObject]
            
            return items.map { soundFile in
                            return RecordedAudioFile(identifier: NSUUID(UUIDString: soundFile["Identifier"] as! String)!,
                                                        name: soundFile["Name"] as! String,
                                                        url: soundFileUrl(soundFile["URL"] as! String))
                        }
            
        } catch let error as NSError {
            NSLog("Error loading recordedSoundFilePList file: \(error.localizedDescription)")
            return [SoundFile]()
        }
    }
    
    func saveRecordedSoundFileToPlist(identifier: NSUUID, name: String, URL: NSURL) {
        
        do {
            var soundFilesDictionaries = try existingRecordDictionaries()
            
            soundFilesDictionaries.append(
                ["Identifier": identifier.UUIDString,
                    "Name": name,
                    "URL": URL.lastPathComponent!])
            
            let serializedData =
                try NSPropertyListSerialization.dataWithPropertyList(soundFilesDictionaries, format: NSPropertyListFormat.XMLFormat_v1_0, options:0)
           
            serializedData.writeToURL(pListUrl, atomically: true)
            
        } catch let error as NSError {
            NSLog("Error saving recordedSoundFilePList file: \(error.localizedDescription)")
        }
    }
    
    func deleteRecordedSoundFile(identifier: NSUUID) throws {
        
        var soundFileDictionariesWithoutDeleted = [[String: String]]()
        let soundFilesDictionaries = try existingRecordDictionaries()
            
        soundFilesDictionaries.forEach{ soundFileDictionary in
            if soundFileDictionary["Identifier"] != identifier.UUIDString {
                soundFileDictionariesWithoutDeleted.append(soundFileDictionary)
            }
        }
            
        let serializedData =
            try NSPropertyListSerialization.dataWithPropertyList(soundFileDictionariesWithoutDeleted, format: NSPropertyListFormat.XMLFormat_v1_0, options:0)
            
        serializedData.writeToURL(pListUrl, atomically: true)
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
    
    private func soundFileUrl(fileName: String) -> NSURL {
     
        return documentsDirectory.URLByAppendingPathComponent(fileName)
    }
}