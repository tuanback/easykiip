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
  
  func testIncreaseNumberOfCorrectAnswer_SetIsLearnedToTrue() {
    var sut = PracticeHistory()
    
    // when
    sut.increaseNumberOfCorrectAnswerByOne()
    
    // then
    XCTAssertTrue(sut.isLearned)
  }
  
  func testIncreaseNumberOfWrongAnswer_SetIsLearnedToTrue() {
    var sut = PracticeHistory()
    sut.increaseNumberOfWrongAnswerByOne()
    XCTAssertTrue(sut.isLearned)
  }
  
  func test_increaseNumberCorrectAnswer2Times_SetNumberOfCorrectAnswerTo2() {
    var sut = PracticeHistory()
    
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfCorrectAnswerByOne()
    
    XCTAssertEqual(sut.numberOfCorrectAnswer, 2)
  }
  
  func test_increaseNumberWrongAnswer2Times_SetNumberOfWrongAnswerTo2() {
    var sut = PracticeHistory()
    
    sut.increaseNumberOfWrongAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    
    XCTAssertEqual(sut.numberOfWrongAnswer, 2)
  }
  
  func test_increaseNumberOfCorrectAnswer1Time_numberOfWrongAnswer1Time_IncreaseNumberOfTestTakenTo2() {
    var sut = PracticeHistory()
    
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    
    XCTAssertEqual(sut.numberOfTestTaken, 2)
  }
  
  func test_increaseNumberOfCorrectAnswer2Times_numberOfWrongAnswer1Time_IncreaseNumberOfTestTakenTo3() {
    var sut = PracticeHistory()
    
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    
    XCTAssertEqual(sut.numberOfTestTaken, 3)
  }
  
  func test_increaseNumberOfCorrectAnswer2Times_numberOfWrongAnswer2Times_IncreaseNumberOfTestTakenTo4() {
    var sut = PracticeHistory()
    
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    
    XCTAssertEqual(sut.numberOfTestTaken, 4)
  }
  
  func test_changeNumberOfCorrectAndWrongAnswer_changeLastTimeTest() {
    
    let timeBeforeTest = Date()
    
    var sut = PracticeHistory()
    sut.increaseNumberOfWrongAnswerByOne()
    sut.increaseNumberOfCorrectAnswerByOne()
    
    XCTAssertTrue(sut.lastTimeTest >= timeBeforeTest && sut.lastTimeTest <= Date())
  }
  
  func testSetTestTakenData_NumberOfTestTaken_SmallerThanNumberOfCorrectAnswer_ThrowError() {
    var sut = PracticeHistory()
    let numberOfTestTaken: UInt = 3
    let numberOfCorrectAnswer: UInt = 5
    
    XCTAssertThrowsError(try sut.setTestTakenData(numberOfTestTaken: numberOfTestTaken,
                                                  numberOfCorrectAnswer: numberOfCorrectAnswer, lastTimeTest: Date()))
  }
  
  func testSetTestTakenData_NumberOfTest_SmallerThanCurrentNumberOfTest_DontSetNewData() throws {
    var sut = PracticeHistory()
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    
    let numberOfTestTaken: UInt = 1
    let numberOfCorrectAnswer: UInt = 1
    try sut.setTestTakenData(numberOfTestTaken: numberOfTestTaken,
                             numberOfCorrectAnswer: numberOfCorrectAnswer,
                             lastTimeTest: Date())
    
    XCTAssertEqual(sut.numberOfTestTaken, 2)
    XCTAssertEqual(sut.numberOfCorrectAnswer, 1)
    XCTAssertEqual(sut.numberOfWrongAnswer, 1)
    XCTAssertEqual(sut.isLearned, true)
  }
  
  func testSetTestTakenData_NumberOfTest_GreaterThanCurrentNumberOfTest_SetNewData() throws {
    var sut = PracticeHistory()
    
    let numberOfTestTaken: UInt = 1
    let numberOfCorrectAnswer: UInt = 1
    try sut.setTestTakenData(numberOfTestTaken: numberOfTestTaken,
                             numberOfCorrectAnswer: numberOfCorrectAnswer,
                             lastTimeTest: Date())
    
    XCTAssertEqual(sut.numberOfTestTaken, 1)
    XCTAssertEqual(sut.numberOfCorrectAnswer, 1)
    XCTAssertEqual(sut.numberOfWrongAnswer, 0)
    XCTAssertEqual(sut.isLearned, true)
  }
  
  // Test First Learn Date
  func testSetIsLearn_SetFirstLearnDate() {
    var sut = PracticeHistory()
    
    sut.increaseNumberOfWrongAnswerByOne()
    
    XCTAssertNotNil(sut.firstLearnDate)
  }
  
  // Test Proficiency Calculation
  func test_init_setProficiencyTo0() {
    let sut = PracticeHistory()
    XCTAssertEqual(sut.proficiency, 0)
  }
  
  func test_markAsIsMastered_setIsLearnedAndProficiencyTo100() {
    var sut = PracticeHistory()
    
    sut.markAsIsMastered()
    
    XCTAssertEqual(sut.isMastered, true)
    XCTAssertEqual(sut.isLearned, true)
    XCTAssertEqual(sut.proficiency, 100)
  }
  
}
