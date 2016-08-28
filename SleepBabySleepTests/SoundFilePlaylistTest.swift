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
    let emptyPlaylist = SoundFilePlaylist(soundFiles:[SoundFile]())
    
    override func setUp() {
        
        let soundFiles = [soundFile1, soundFile2]
        
        playlist = SoundFilePlaylist(soundFiles: soundFiles)
    }
    
    
    func testNextOnEmptyPlaylistReturnsNil() {
        
        XCTAssertNil(emptyPlaylist.next())
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
    
    func testNextStartsFromTheBeginngWhenCalledOnTheLastItem() {
        
        playlist!.next()
        playlist!.next()
        let soundFile = playlist!.next()
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile1, soundFile)
    }
    
    func testFirstOnEmptyPlaylistReturnsNil() {
        
        XCTAssertNil(emptyPlaylist.first())
    }
    
    func testFirstReturnsFirstPlaylistItem() {
        
        let soundFile = playlist!.first()
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile1, soundFile)
    }
    
    func testNextAfterFirstReturnsTheSecondItem() {
        
        playlist!.first()
        let soundFile = playlist!.next()
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile2, soundFile)
    }
}