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

    func testState4Of4Returns4() {
        XCTAssertEqual("4", assetImageStateOf4Images(4).imageNumber())
    }
    
    func testState5Of4Returns1() {
        XCTAssertEqual("1", assetImageStateOf4Images(5).imageNumber())
    }
    
    func testState8Of4Returns4() {
        XCTAssertEqual("4", assetImageStateOf4Images(8).imageNumber())
    }
    
    func testState9Of4Returns1() {
        XCTAssertEqual("1", assetImageStateOf4Images(9).imageNumber())
    }
    
    func testState10Of4Returns2() {
        XCTAssertEqual("2", assetImageStateOf4Images(10).imageNumber())
    }
    
    func testState12Of4Returns4() {
        XCTAssertEqual("4", assetImageStateOf4Images(12).imageNumber())
    }
    
    func testState13Of4Returns1() {
        XCTAssertEqual("1", assetImageStateOf4Images(13).imageNumber())
    }
    
    private func assetImageStateOf4Images(_ state: Int) -> AssetImageState {
        return AssetImageState(currentState: state,imageCount: 4)
    }
}
