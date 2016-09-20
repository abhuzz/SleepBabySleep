//
//  AssetImages.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 20/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

protocol TileImages {
    func nextImage() throws -> UIImage
}

class AssetTileImages: TileImages {
    
    private let fileManager = FileManager.default
    private let stateFilePath: URL
    
    init() {
        let documentsDirectory =
            fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        stateFilePath =
            documentsDirectory.appendingPathComponent("imageState.txt")
    }
    
    func nextImage() throws -> UIImage {
        
        let nextNumber = try nextImageNumber()
        let name = "Tile_\(nextNumber)"
        
        guard let image = UIImage(named: name) else {
            NSLog("Image not found: \(name)")
            return UIImage()
        }
        
        return image
    }

    private func nextImageNumber() throws -> String {
        
        var nextNumber: String
        
        do {
            let currentNumber = try String(contentsOf: stateFilePath)
           
            if let currentNumberAsInt = Int(currentNumber) {
                nextNumber = String(currentNumberAsInt + 1)
            } else {
                NSLog("NextNumber from imageStateFile was not numeric: \(currentNumber) -> using 1")
                nextNumber = "1"
            }
        } catch let error as NSError {
            NSLog("Reading nextNumberState from \(stateFilePath) -> using 1. Error: \(error.localizedDescription)")
            nextNumber = "1"
        }
        
        do {
            try nextNumber.write(to: stateFilePath, atomically: true, encoding: .utf8)
        } catch let error as NSError {
            NSLog("Error saving nextNumberState: \(error.localizedDescription)")
            throw error
        }
        
        return nextNumber
    }
}
