//
//  AssetTileImages.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 20/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import SleepBabySleep

class FakeImageNumberStateFile: ImageNumberStateFile {
    
    private var numberToReturn: String?
    private(set) var WrittenContent: String?
    
    init(startValue: String) {
        numberToReturn = startValue
    }
    
    
    func read() throws -> String {
        return numberToReturn ?? "-1"
    }
    
    func write(content: String) throws {
        WrittenContent = content
    }
}

class AssetTileImagesTest: XCTestCase {
    
    private var testInstance: ImageNumberState?
    private var fakeImageNumberStateFile: FakeImageNumberStateFile?
    
    override func setUp() {
        super.setUp()
        
        fakeImageNumberStateFile = FakeImageNumberStateFile(startValue: "0")
        testInstance = ImageNumberState(imageNumberStateFile: fakeImageNumberStateFile!)
    }
    
    func testFirstCallReturns1() {
        
        XCTAssertEqual("1", nextImageNumber().imageNumber())
    }
    
    func testFirstCallWritesState() {
        
        _ = nextImageNumber()
        XCTAssertEqual("1", fakeImageNumberStateFile?.WrittenContent)
    }
    
    func nextImageNumber() -> AssetImageState {
        return try! testInstance!.nextImageNumber()
    }
}
