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
        XCTAssertEqual("1", assetImageStateOf4Images(1).imageNumber())
    }

    func testState4Of4Returns1() {
        XCTAssertEqual("4", assetImageStateOf4Images(4).imageNumber())
    }
    
    
    private func assetImageStateOf4Images(_ state: Int) -> AssetImageState {
        return AssetImageState(currentState: state,imageCount: 4)
    }
}
