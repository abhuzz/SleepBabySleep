//
//  Playlist.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 28/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class SoundFilePlaylist {
    
    private var soundFiles = [SoundFile]()
    private var currentRow = -1
    
    init(soundFiles: [SoundFile]) {
        self.soundFiles = soundFiles
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