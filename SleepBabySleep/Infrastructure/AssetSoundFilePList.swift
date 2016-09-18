//
//  AssetSoundFilePList.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 06/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class AssetSoundFilePList {
    
    private let fileManager = FileManager.default
    private let plistUrl = Bundle.main.url(forResource: "AssetSoundFiles", withExtension: "plist")
    
    func assetSoundFilesInPList() throws -> [SoundFile] {
        
        var soundFilesInPList = [SoundFile]()
        
        var format = PropertyListSerialization.PropertyListFormat.xml
        let plistData = try? Data(contentsOf: plistUrl!)

        do {
            let items =
                try PropertyListSerialization.propertyList(from: plistData!, options: PropertyListSerialization.MutabilityOptions(), format: &format) as! [AnyObject]
            
            soundFilesInPList =
                items.map { soundFile in
                    if let image = UIImage(named: soundFile["ImageName"] as! String) {
                        return AssetSoundFile(Name: soundFile["Name"]!! as! String,
                                              File: soundFile["File"]!! as! String,
                                              Extension: soundFile["Extension"] as! String,
                                              Image: image)
                    }
                    
                    return AssetSoundFile(Name: soundFile["Name"]!! as! String,
                                          File: soundFile["File"]!! as! String,
                                          Extension: soundFile["Extension"] as! String)
                }
            
        } catch let error as NSError {
            NSLog("Error loading staticAssetsPList file: \(error.localizedDescription)")
            throw error
        }
        
        return soundFilesInPList
    }
}
