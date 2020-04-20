//
//  PracticeHistoryTests.swift
//  EasyKIIPKitTests
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
@testable import EasyKIIPKit

class PracticeHistoryTests: XCTestCase {
  
  func test_init_setIsLearnedFalse() {
    let sut = PracticeHistory()
    XCTAssertFalse(sut.isLearned)
  }
  
  func test_init_setNumberOfTestTakenToZero() {
    let sut = PracticeHistory()
    XCTAssertEqual(sut.numberOfTestTaken, 0)
  }
  
  func test_init_setNumberOfCorrectAnswerToZero() {
    let sut = PracticeHistory()
    XCTAssertEqual(sut.numberOfCorrectAnswer, 0)
  }
  
  func test_init_setNumberOfWrongAnswerToZero() {
    let sut = PracticeHistory()
    XCTAssertEqual(sut.numberOfWrongAnswer, 0)
  }
  
  func test_init_setLastTimeTest() {
    let dateBeforeTest = Date()
    let sut = PracticeHistory()
    XCTAssertTrue(sut.lastTimeTest >= dateBeforeTest)
    XCTAssertTrue(Date() >= sut.lastTimeTest)
  }
  
  func test_init_setProficiencyTo0() {
    let sut = PracticeHistory()
    XCTAssertEqual(sut.proficiency, 0)
  }
  
}
