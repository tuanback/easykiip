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
  
  func test_setNumberOfTest_Correct_WrongAnswers_setValuesCorrectly() throws {
    
    let numberOfTestTaken = UInt.random(in: 0...10)
    let numberOfCorrectAnswer = UInt.random(in: 0...numberOfTestTaken)
    
    var sut = PracticeHistory()
    try sut.setTestData(numberOfTestTaken: numberOfTestTaken,
                    numberOfCorrectAnswer: numberOfCorrectAnswer)
    
    XCTAssertEqual(sut.numberOfTestTaken, numberOfTestTaken)
    XCTAssertEqual(sut.numberOfCorrectAnswer, numberOfCorrectAnswer)
    XCTAssertEqual(sut.numberOfWrongAnswer, numberOfTestTaken - numberOfCorrectAnswer)
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
