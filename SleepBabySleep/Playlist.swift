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
    
    func next() -> SoundFile? {
        currentRow += 1
        return soundFiles[currentRow]
    }
}