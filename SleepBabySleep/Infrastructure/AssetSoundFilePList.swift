//
//  AssetSoundFilePList.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 06/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class AssetSoundFilePList {
    
    private let fileManager = NSFileManager.defaultManager()
    private let plistUrl = NSBundle.mainBundle().URLForResource("AssetSoundFiles", withExtension: "plist")
    
    func assetSoundFilesInPList() throws -> [SoundFile] {
        
        var soundFilesInPList = [SoundFile]()
        
        var format = NSPropertyListFormat.XMLFormat_v1_0
        let plistData = NSData(contentsOfURL: plistUrl!)

        do {
            let items =
                try NSPropertyListSerialization.propertyListWithData(plistData!, options: .Immutable, format: &format) as! [AnyObject]
            
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