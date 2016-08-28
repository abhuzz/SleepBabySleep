//
//  Playlist.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 28/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

protocol Playlist {
    associatedtype PlaylistItemType
    
    func next() -> PlaylistItemType?
}

class SoundFilePlaylist {
    typealias PlaylistItemType = SoundFile
    
    private var soundFiles = [SoundFile]()
    
    init(soundFiles: [SoundFile]) {
        self.soundFiles = soundFiles
    }
    
    func next() -> PlaylistItemType? {
        
        return soundFiles.first
    }
}