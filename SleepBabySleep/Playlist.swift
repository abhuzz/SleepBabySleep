//
//  Playlist.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 28/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class SoundFilePlaylist {
    
    private var currentRow = -1
    
    private(set) var soundFiles: [SoundFile]
    
    
    init(soundFiles: [SoundFile]) {
        self.soundFiles = soundFiles
    }
    
    
    var count: Int {
        get {
            return soundFiles.count
        }
    }
    
    func byRow(row: Int) -> SoundFile? {
        
        guard ( row >= 0 && row < soundFiles.count ) else { return nil }
        
        return soundFiles[row]
    }
    
    func first() -> SoundFile? {
        return soundFiles.first
    }
    
    func next() -> SoundFile? {
        
        guard soundFiles.count > 0 else { return nil }
        
        if currentRow == soundFiles.count - 1 {
            currentRow = 0
        } else {
            currentRow += 1
        }
        
        return soundFiles[currentRow]
    }
}