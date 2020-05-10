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
    let sut = PracticeHistory(id: 0)
    XCTAssertFalse(sut.isLearned)
  }
  
  func test_init_setNumberOfTestTakenToZero() {
    let sut = PracticeHistory(id: 0)
    XCTAssertEqual(sut.numberOfTestTaken, 0)
  }
  
  func test_init_setNumberOfCorrectAnswerToZero() {
    let sut = PracticeHistory(id: 0)
    XCTAssertEqual(sut.numberOfCorrectAnswer, 0)
  }
  
  func test_init_setNumberOfWrongAnswerToZero() {
    let sut = PracticeHistory(id: 0)
    XCTAssertEqual(sut.numberOfWrongAnswer, 0)
  }
  
  func test_init_doesntSetLastTimeTest() {
    let sut = PracticeHistory(id: 0)
    XCTAssertNil(sut.lastTimeTest)
  }
  
  func testIncreaseNumberOfCorrectAnswer_SetIsLearnedToTrue() {
    let sut = PracticeHistory(id: 0)
    
    // when
    sut.increaseNumberOfCorrectAnswerByOne()
    
    // then
    XCTAssertTrue(sut.isLearned)
  }
  
  func testIncreaseNumberOfWrongAnswer_SetIsLearnedToTrue() {
    let sut = PracticeHistory(id: 0)
    sut.increaseNumberOfWrongAnswerByOne()
    XCTAssertTrue(sut.isLearned)
  }
  
  func test_increaseNumberCorrectAnswer2Times_SetNumberOfCorrectAnswerTo2() {
    let sut = PracticeHistory(id: 0)
    
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfCorrectAnswerByOne()
    
    XCTAssertEqual(sut.numberOfCorrectAnswer, 2)
  }
  
  func test_increaseNumberWrongAnswer2Times_SetNumberOfWrongAnswerTo2() {
    let sut = PracticeHistory(id: 0)
    
    sut.increaseNumberOfWrongAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    
    XCTAssertEqual(sut.numberOfWrongAnswer, 2)
  }
  
  func test_increaseNumberOfCorrectAnswer1Time_numberOfWrongAnswer1Time_IncreaseNumberOfTestTakenTo2() {
    let sut = PracticeHistory(id: 0)
    
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    
    XCTAssertEqual(sut.numberOfTestTaken, 2)
  }
  
  func test_increaseNumberOfCorrectAnswer2Times_numberOfWrongAnswer1Time_IncreaseNumberOfTestTakenTo3() {
    let sut = PracticeHistory(id: 0)
    
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    
    XCTAssertEqual(sut.numberOfTestTaken, 3)
  }
  
  func test_increaseNumberOfCorrectAnswer2Times_numberOfWrongAnswer2Times_IncreaseNumberOfTestTakenTo4() {
    let sut = PracticeHistory(id: 0)
    
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    
    XCTAssertEqual(sut.numberOfTestTaken, 4)
  }
  
  func test_changeNumberOfCorrectAndWrongAnswer_changeLastTimeTest() {
    
    let timeBeforeTest = Date()
    
    let sut = PracticeHistory(id: 0)
    sut.increaseNumberOfWrongAnswerByOne()
    sut.increaseNumberOfCorrectAnswerByOne()
    
    XCTAssertNotNil(sut.lastTimeTest)
    XCTAssertTrue(sut.lastTimeTest! >= timeBeforeTest && sut.lastTimeTest! <= Date())
  }
  
  func testSetTestTakenData_NumberOfTest_SmallerThanCurrentNumberOfTest_DontSetNewData() {
    let sut = PracticeHistory(id: 0)
    sut.increaseNumberOfCorrectAnswerByOne()
    sut.increaseNumberOfWrongAnswerByOne()
    
    let numberOfTestTaken: UInt = 1
    let numberOfCorrectAnswer: UInt = 1
    sut.setTestTakenData(isMastered: false,
                         numberOfTestTaken: numberOfTestTaken,
                         numberOfCorrectAnswer: numberOfCorrectAnswer, firstLearnDate: Date(),
                         lastTimeTest: Date())
    
    XCTAssertEqual(sut.numberOfTestTaken, 2)
    XCTAssertEqual(sut.numberOfCorrectAnswer, 1)
    XCTAssertEqual(sut.numberOfWrongAnswer, 1)
    XCTAssertEqual(sut.isLearned, true)
  }
  
  func testSetTestTakenData_NumberOfTest_GreaterThanCurrentNumberOfTest_SetNewData() {
    let sut = PracticeHistory(id: 0)
    
    let numberOfTestTaken: UInt = 1
    let numberOfCorrectAnswer: UInt = 1
    sut.setTestTakenData(isMastered: false,
                         numberOfTestTaken: numberOfTestTaken,
                         numberOfCorrectAnswer: numberOfCorrectAnswer, firstLearnDate: Date(),
                         lastTimeTest: Date())
    
    XCTAssertEqual(sut.numberOfTestTaken, 1)
    XCTAssertEqual(sut.numberOfCorrectAnswer, 1)
    XCTAssertEqual(sut.numberOfWrongAnswer, 0)
    XCTAssertEqual(sut.isLearned, true)
  }
  
  // Test First Learn Date
  func testSetIsLearn_SetFirstLearnDate() {
    let sut = PracticeHistory(id: 0)
    
    sut.increaseNumberOfWrongAnswerByOne()
    
    XCTAssertNotNil(sut.firstLearnDate)
  }
}
