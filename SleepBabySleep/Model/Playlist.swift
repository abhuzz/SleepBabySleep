//
//  Playlist.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 28/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class SoundFilePlaylist {
    
    private var currentRow = 0
    
    private(set) var soundFiles: [SoundFile]
    
    
    init(soundFiles: [SoundFile]) {
        self.soundFiles = soundFiles
    }
    
    
    var count: Int {
        get {
            return soundFiles.count
        }
    }
    
    var number: Int {
        get {
            return currentRow
        }
    }
    
    var index: Int {
        get {
            return currentRow;
        }
    }
    
    func first() -> SoundFile? {
        
        currentRow = 0
        
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
    
    func previous() -> SoundFile? {
        
        guard soundFiles.count > 0 else { return nil }
        
        if currentRow < 1 {
            currentRow = soundFiles.count - 1
        } else {
            currentRow -= 1
        }
        
        return soundFiles[currentRow]
    }
    
    func jumptoRow(_ row: Int) -> SoundFile? {
        
        guard let soundFile = byRow(row) else { return nil }
        
        currentRow = row
        
        return soundFile
    }
    
    func byRow(_ row: Int) -> SoundFile? {
        
        guard ( row >= 0 && row < soundFiles.count ) else { return nil }
        
        return soundFiles[row]
    }
    
    func indexForUuid(uuid: UUID) -> Array<SoundFile>.Index? {
        
        return soundFiles.index(where: { $0.Identifier == uuid })
    }
}
