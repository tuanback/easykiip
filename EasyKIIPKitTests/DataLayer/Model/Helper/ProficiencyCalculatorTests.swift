//
//  ProficiencyCalculatorTests.swift
//  EasyKIIPKitTests
//
//  Created by Real Life Swift on 2020/04/21.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import SwiftDate
@testable import EasyKIIPKit

class ProficiencyCalculatorTests: XCTestCase {
  
  func testCalulate_JustInitVocab_ProficiencyIsZero() {
    let vocab = makeVocab()
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 0)
  }
  
  func testCalculate_IsMasteredVocab_ProficiecncyIs100() {
    let vocab = makeVocab()
    vocab.markAsIsMastered()
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 100)
  }
  
  func testCalculate_IsLearnedVocab_OneTimeTestTaken_CorrectAnswer_LastTimeTakenToday_ProficiencyIs100() {
    let vocab = makeVocab()
    vocab.increaseNumberOfCorrectAnswerByOne()
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 100)
  }
  
  func testCalculate_2TimeTestTaken_OneCorrect_OneWrong_LastTimeTakenToday_ProficiencyIs100() {
    // given
    let vocab = makeVocab()
    
    // when
    vocab.increaseNumberOfCorrectAnswerByOne()
    vocab.increaseNumberOfWrongAnswerByOne()
    
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    
    // then
    XCTAssertEqual(proficiency, 100)
  }
  
  func testCalculate_1TimeTestTaken_WrongAnswer_LastTimeTakenToday_ProficiencyIs0() {
    let vocab = makeVocab()
    vocab.increaseNumberOfWrongAnswerByOne()
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 0)
  }
  
  // 1...6
  func testCalculate_1TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs51() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 1
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer, firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 51)
  }
  
  func testCalculate_1TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs26() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 1
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 26)
  }
  
  func testCalculate_6TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs51() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 6
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 51)
  }
  
  func testCalculate_6TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs26() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 6
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 26)
  }
  
  
  // 7...12
  func testCalculate_7TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs64() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 7
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 64)
  }
  
  func testCalculate_7TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs40() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 7
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 40)
  }
  
  func testCalculate_12TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs64() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 12
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 64)
  }
  
  func testCalculate_12TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs40() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 12
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 40)
  }
  
  // 13...18
  func testCalculate_13TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs75() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 13
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 75)
  }
  
  func testCalculate_13TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs56() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 13
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 56)
  }
  
  func testCalculate_18TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs75() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 18
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 75)
  }
  
  func testCalculate_18TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs56() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 18
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 56)
  }
  
  // 19...24
  func testCalculate_19TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs84() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 19
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 84)
  }
  
  func testCalculate_19TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs70() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 19
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 70)
  }
  
  func testCalculate_24TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs84() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 24
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 84)
  }
  
  func testCalculate_24TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs70() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 24
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 70)
  }
  
  // 25...30
  func testCalculate_25TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs91() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 25
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 91)
  }
  
  func testCalculate_25TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs82() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 25
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 82)
  }
  
  func testCalculate_30TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs91() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 30
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 91)
  }
  
  func testCalculate_30TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs82() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 30
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 82)
  }
  
  // 31...36
  func testCalculate_31TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs96() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 31
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 96)
  }
  
  func testCalculate_31TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs92() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 31
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 92)
  }
  
  func testCalculate_36TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs96() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 36
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 96)
  }
  
  func testCalculate_36TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs96() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 36
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 92)
  }
  
  // 37...42
  func testCalculate_37TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs99() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 37
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 99)
  }
  
  func testCalculate_37TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs98() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 37
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 98)
  }
  
  func testCalculate_42TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs99() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 42
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 99)
  }
  
  func testCalculate_42TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs98() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 42
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 98)
  }
  
  // 43 and 99
  func testCalculate_43TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs100() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 43
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 100)
  }
  
  func testCalculate_43TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs100() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 43
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 100)
  }
  
  func testCalculate_99TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs100() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 99
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 100)
  }
  
  func testCalculate_99TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs100() {
    let vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 99
    let numberOfCorrectAnswer = numberOfTakenTest
    vocab.setTestTakenData(isMastered: false,
                           numberOfTestTaken: numberOfTakenTest,
                           numberOfCorrectAnswer: numberOfCorrectAnswer,
                           firstLearnDate: lastTimeTest,
                           lastTimeTest: lastTimeTest)
    let proficiency = ProficiencyCalculator.calculate(vocab: vocab)
    XCTAssertEqual(proficiency, 100)
  }
  
  // MARK: Helper functions
  private func makeVocab() -> Vocab {
    return Vocab(id: 0, word: "", translations: [:])
  }
}
