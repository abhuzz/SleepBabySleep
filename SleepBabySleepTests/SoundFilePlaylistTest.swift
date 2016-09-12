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

    let soundFile1 = FakeSoundFile()
    let soundFile2 = FakeSoundFile()
    
    var playlist: SoundFilePlaylist?
    let emptyPlaylist = SoundFilePlaylist(soundFiles:[SoundFile]())
    
    override func setUp() {
        
        let soundFiles = [soundFile1 as SoundFile, soundFile2 as SoundFile]
        
        playlist = SoundFilePlaylist(soundFiles: soundFiles)
    }
    
    
    func testNextOnEmptyPlaylistReturnsNil() {
        
        XCTAssertNil(emptyPlaylist.next())
    }
    
    func testNextReturnsFirstSoundfile() {
        
        let soundFile = playlist!.next() as? FakeSoundFile
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile1, soundFile!)
    }
    
    func testNextNextReturnsSecondSoundFile() {
        
        _ = playlist!.next()
        let soundFile = playlist!.next() as? FakeSoundFile
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile2, soundFile)
    }
    
    func testNextStartsFromTheBeginngWhenCalledOnTheLastItem() {
        
        _ = playlist!.next()
        _ = playlist!.next()
        let soundFile = playlist!.next() as? FakeSoundFile
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile1, soundFile)
    }
    
    func testFirstOnEmptyPlaylistReturnsNil() {
        
        XCTAssertNil(emptyPlaylist.first())
    }
    
    func testFirstReturnsFirstPlaylistItem() {
        
        let soundFile = playlist!.first() as? FakeSoundFile
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile1, soundFile)
    }
    
    func testNextAfterFirstReturnsTheSecondItem() {
        
        _ = playlist!.first()
        let soundFile = playlist!.next() as? FakeSoundFile
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile2, soundFile)
    }
    
    func testPreviousReturnsTheLastItwm() {
        
        let soundFile = playlist!.previous() as? FakeSoundFile
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile2, soundFile)
    }
    
    func testPreviousTwoTimesReturnsTheFirstItem() {
        
        _ = playlist!.previous()
        let soundFile = playlist!.previous() as? FakeSoundFile
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile1, soundFile)
    }
    
    func testPreviousAterFirstReturnsTheLastItem() {
        
        _ = playlist!.first()
        let soundFile = playlist!.previous() as? FakeSoundFile
        
        XCTAssertNotNil(soundFile)
        XCTAssertEqual(soundFile2, soundFile)
    }
}
