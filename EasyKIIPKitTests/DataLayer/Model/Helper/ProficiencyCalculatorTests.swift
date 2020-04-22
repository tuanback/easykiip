//
//  ProficiencyCalculatorTests.swift
//  EasyKIIPKitTests
//
//  Created by Real Life Swift on 2020/04/21.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
@testable import EasyKIIPKit

class ProficiencyCalculatorTests: XCTestCase {
  
  func testCalulate_JustInitVocab_ProficiencyIsZero() {
    let vocab = makeVocab()
    
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 0)
  }
  
  func testCalculate_IsMasteredVocab_ProficiecncyIs100() {
    var vocab = makeVocab()
    vocab.markAsIsMastered()
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 100)
  }
  
  func testCalculate_IsLearnedVocab_OneTimeTestTaken_CorrectAnswer_LastTimeTakenToday_ProficiencyIs100() {
    var vocab = makeVocab()
    vocab.practiceHistory.increaseNumberOfCorrectAnswerByOne()
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 100)
  }
  
  func testCalculate_2TimeTestTaken_OneCorrect_OneWrong_LastTimeTakenToday_ProficiencyIs100() {
    // given
    var vocab = makeVocab()
    
    // when
    vocab.practiceHistory.increaseNumberOfCorrectAnswerByOne()
    vocab.practiceHistory.increaseNumberOfWrongAnswerByOne()
    
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    
    // then
    XCTAssertEqual(proficiency, 100)
  }
  
  func testCalculate_1TimeTestTaken_WrongAnswer_LastTimeTakenToday_ProficiencyIs0() {
    var vocab = makeVocab()
    vocab.practiceHistory.increaseNumberOfCorrectAnswerByOne()
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 0)
  }
  
  func testCalculate_1TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs51() {
    var vocab = makeVocab()
    
    vocab.practiceHistory.setTestTakenData(numberOfTestTaken: 1, numberOfCorrectAnswer: 1, lastTimeTest: Date())
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 51)
  }
  
  // MARK: Helper functions
  private func makeVocab() -> Vocab {
    return Vocab(id: 0, word: "", translations: [])
  }
}
