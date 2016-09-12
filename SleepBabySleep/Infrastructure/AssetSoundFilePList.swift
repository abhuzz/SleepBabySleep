//
//  AssetSoundFilePList.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 06/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class AssetSoundFilePList {
    
    fileprivate let fileManager = FileManager.default
    fileprivate let plistUrl = Bundle.main.url(forResource: "AssetSoundFiles", withExtension: "plist")
    
    func assetSoundFilesInPList() throws -> [SoundFile] {
        
        var soundFilesInPList = [SoundFile]()
        
        var format = PropertyListSerialization.PropertyListFormat.xml
        let plistData = try? Data(contentsOf: plistUrl!)

        do {
            let items =
                try PropertyListSerialization.propertyList(from: plistData!, options: PropertyListSerialization.MutabilityOptions(), format: &format) as! [AnyObject]
            
            soundFilesInPList =
                items.map { soundFile in
                    return AssetSoundFile(Name: soundFile["Name"]!! as! String, File: soundFile["File"]!! as! String, Extension: soundFile["Extension"] as! String)
                }
            
        } catch let error as NSError {
            NSLog("Error loading staticAssetsPList file: \(error.localizedDescription)")
            throw error
        }
        
        return soundFilesInPList
    }
}
