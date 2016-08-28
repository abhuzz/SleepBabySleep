//
//  PlaylistTests.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 28/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import SleepBabySleep


class SoundFilePlaylistTest: XCTestCase {

    let soundFile1 = SoundFile(Name: "1", File: "1", Extension: "")
    let soundFile2 = SoundFile(Name: "2", File: "2", Extension: "")
    
    var playlist: SoundFilePlaylist?
    
    override func setUp() {
        
        let soundFiles = [soundFile1, soundFile2]
        
        playlist = SoundFilePlaylist(soundFiles: soundFiles)
    }
    
    
    func testNextReturnsFirstSoundfile() {
        
        let soundFile = playlist!.next()
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile1, soundFile!)
    }
    
    func testNextNextReturnsSecondSoundFile() {
        
        playlist!.next()
        let soundFile = playlist!.next()
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile2, soundFile)
    }
}