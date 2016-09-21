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
    
    private var imageNumberState = ImageNumberState()
    
    func nextImage() throws -> UIImage {
        
        let nextNumber = try imageNumberState.nextImageNumber()
        let name = "Tile_\(nextNumber)"
        
        guard let image = UIImage(named: name) else {
            NSLog("Image not found: \(name)")
            return UIImage()
        }
        
        return image
    }

}

class ImageNumberState {
    
    private var imageNumberStateFile: ImageNumberStateFile
    
    init(imageNumberStateFile: ImageNumberStateFile = ImageNumberStateTextFile()) {
        self.imageNumberStateFile = imageNumberStateFile
    }
    
    func nextImageNumber() throws -> String {
        
        let currentState = loadCurrentState()
        
        let newState = incrementCurrentState(currentState: currentState)
        
        try saveModifiedState(state: newState)
        
        return newState
    }
    
    func loadCurrentState() -> String {
     
        do {
            return try imageNumberStateFile.read()
        } catch let error as NSError {
            NSLog("Reading nextNumberState -> using 1. Error: \(error.localizedDescription)")
            return "1"
        }
    }
    
    func incrementCurrentState(currentState: String) -> String {
        
        if let currentNumberAsInt = Int(currentState) {
            return String(currentNumberAsInt + 1)
        } else {
            NSLog("NextNumber from imageStateFile was not numeric: \(currentState) -> using 1")
            return "1"
        }
    }
    
    func saveModifiedState(state: String) throws {
        
        do {
            try imageNumberStateFile.write(content: state)
        } catch let error as NSError {
            NSLog("Error saving nextNumberState: \(error.localizedDescription)")
            throw error
        }
    }
}

protocol ImageNumberStateFile {
    func read() throws -> String
    func write(content: String) throws
}

class ImageNumberStateTextFile: ImageNumberStateFile {
    
    private let fileManager = FileManager.default
    private let stateFilePath: URL
    
    init() {
        let documentsDirectory =
            fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        stateFilePath =
            documentsDirectory.appendingPathComponent("imageState.txt")
    }

    func read() throws -> String {
        return try String(contentsOf: stateFilePath)
    }
    
    func write(content: String) throws {
        try content.write(to: stateFilePath, atomically: true, encoding: .utf8)
    }
}

