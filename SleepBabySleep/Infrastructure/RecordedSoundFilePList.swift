//
//  Recoe.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 06/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class RecordedSoundFilesPList {
    
    private let fileManager = FileManager.default
    private var format = PropertyListSerialization.PropertyListFormat.xml
    private let documentsDirectory: URL
    private let pListUrl: URL
    
    
    init() {
        
        documentsDirectory =
            FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
        
        pListUrl =
            documentsDirectory
                .appendingPathComponent("RecordedSoundFiles.plist")
    }
    
    
    func recordedSoundFilesInPList() throws -> [SoundFile] {
        
        guard let plistData = try? Data(contentsOf: pListUrl) else { return [SoundFile]() }
        
        do {
            let items =
                try PropertyListSerialization.propertyList(from: plistData, options: PropertyListSerialization.MutabilityOptions(), format: &format) as! [AnyObject]
            
            return items.map { soundFile in
                            return RecordedAudioFile(identifier: UUID(uuidString: soundFile["Identifier"] as! String)!,
                                                        name: soundFile["Name"] as! String,
                                                        url: soundFileUrl(soundFile["URL"] as! String))
                        }
            
        } catch let error as NSError {
            NSLog("Error loading recordedSoundFilePList file: \(error.localizedDescription)")
            throw error
        }
    }
    
    func saveRecordedSoundFileToPlist(_ identifier: UUID, name: String, URL: Foundation.URL) throws {
        
        do {
            var soundFilesDictionaries = try existingRecordDictionaries()
            
            soundFilesDictionaries.append(
                ["Identifier": identifier.uuidString,
                    "Name": name,
                    "URL": URL.lastPathComponent])
            
            let serializedData =
                try PropertyListSerialization.data(fromPropertyList: soundFilesDictionaries, format: PropertyListSerialization.PropertyListFormat.xml, options:0)
           
            try? serializedData.write(to: pListUrl, options: [.atomic])
            
        } catch let error as NSError {
            NSLog("Error saving recordedSoundFilePList file: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteRecordedSoundFile(_ identifier: UUID) throws {
        
        do {
            
            var soundFileDictionariesWithoutDeleted = [[String: String]]()
            let soundFilesDictionaries = try existingRecordDictionaries()
            
            soundFilesDictionaries.forEach{ soundFileDictionary in
                if soundFileDictionary["Identifier"] != identifier.uuidString {
                    soundFileDictionariesWithoutDeleted.append(soundFileDictionary)
                }
            }
            
            let serializedData =
                try PropertyListSerialization.data(fromPropertyList: soundFileDictionariesWithoutDeleted, format: PropertyListSerialization.PropertyListFormat.xml, options:0)
            
            try? serializedData.write(to: pListUrl, options: [.atomic])
        } catch let error as NSError {
            NSLog("Error deleting a line / save recordedSoundFilePList file: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    private func existingRecordDictionaries() throws -> [[String: String]] {
        
        var soundFilesDictionaries = [[String: String]]()
        
        if let plistData = try? Data(contentsOf: pListUrl) {
            
            let exitingEntries =
                try PropertyListSerialization.propertyList(from: plistData, options: PropertyListSerialization.MutabilityOptions(), format: &format)
            
            soundFilesDictionaries.append(contentsOf: exitingEntries as! [[String: String]])
        }
     
        return soundFilesDictionaries
    }
    
    private func soundFileUrl(_ fileName: String) -> URL {
     
        return documentsDirectory.appendingPathComponent(fileName)
    }
}
