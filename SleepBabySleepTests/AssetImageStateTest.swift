//
//  AssetImageStateTest.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 21/09/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import SleepBabySleep

class AssetImageStateTest: XCTestCase {
    
    
    func testState1Of4Returns1() {
        XCTAssertEqual("1", AssetImageState(currentState: 1,imageCount: 4).imageNumber())
    }
    
}
