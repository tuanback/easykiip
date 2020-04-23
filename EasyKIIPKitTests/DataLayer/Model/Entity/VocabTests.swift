//
//  VocabTests.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import SwiftDate
@testable import EasyKIIPKit

class VocabTests: XCTestCase {

  func test_init_vocab_withID_Word_OneTranslation_SetCorrectly() {
    let id: UInt = 1
    let word = "Word"
    let sut = Vocab(id: id, word: word, translations: [.en: "Hello"])
    
    XCTAssertEqual(sut.id, id)
    XCTAssertEqual(sut.word, word)
    XCTAssertEqual(sut.translations.count, 1)
    XCTAssertEqual(sut.translations[.en], "Hello")
    XCTAssertNil(sut.translations[.vi])
  }
  
  func testInitVocab_setIDCorrectly() {
    let id: UInt = 1
    let sut = Vocab(id: id, word: "", translations: [:])
    XCTAssertEqual(sut.id, id)
  }
  
  func test_init_vocab_setPractiveHistoryLearnedValueEqualFalse() {
    let sut = makeSimpleSut()
    XCTAssertFalse(sut.practiceHistory.isLearned)
  }
  
  func testInitVocab_setPracticeHistoryNumberOfTestTakenToZero() {
    let sut = makeSimpleSut()
    XCTAssertEqual(sut.practiceHistory.numberOfTestTaken, 0)
  }
  
  func testInitVocab_setPracticeHistoryNumberOfCorrectTestTakenToZero() {
    let sut = makeSimpleSut()
    XCTAssertEqual(sut.practiceHistory.numberOfCorrectAnswer, 0)
  }
  
  func testInitVocab_setPracticeHistoryNumberOfWrongTestTakenToZero() {
    let sut = makeSimpleSut()
    XCTAssertEqual(sut.practiceHistory.numberOfWrongAnswer, 0)
  }
  
  func testInitVocab_setIsMasteredToFalse() {
    let sut = makeSimpleSut()
    XCTAssertFalse(sut.practiceHistory.isMastered)
  }
  
  func testInitVocab_firstLearnDateIsNill() {
    let sut = makeSimpleSut()
    XCTAssertNil(sut.practiceHistory.firstLearnDate)
  }
  
  func testInitVocab_lastTimeTestIsNill() {
    let sut = makeSimpleSut()
    XCTAssertNil(sut.practiceHistory.lastTimeTest)
  }
  
  func testMarkAsIsMastered_setPracticeHistoryToMastered() {
    var sut = Vocab(id: 1, word: "", translations: [:])
    
    // when
    sut.markAsIsMastered()
    
    // then
    XCTAssertEqual(sut.practiceHistory.isMastered, true)
  }
  
  // Helper funcs
  private func makeSimpleSut() -> Vocab {
    return Vocab(id: 1, word: "", translations: [:])
  }
}

// Test Proficiency
extension VocabTests {
  func testCalulate_JustInitVocab_ProficiencyIsZero() {
    let vocab = makeVocab()
    XCTAssertEqual(vocab.proficiency, 0)
  }
  
  func testCalculate_IsMasteredVocab_ProficiecncyIs100() {
    var vocab = makeVocab()
    vocab.markAsIsMastered()
    XCTAssertEqual(vocab.proficiency, 100)
  }
  
  func testCalculate_IsLearnedVocab_OneTimeTestTaken_CorrectAnswer_LastTimeTakenToday_ProficiencyIs100() {
    var vocab = makeVocab()
    vocab.increaseNumberOfCorrectAnswerByOne()
    XCTAssertEqual(vocab.proficiency, 100)
  }
  
  func testCalculate_2TimeTestTaken_OneCorrect_OneWrong_LastTimeTakenToday_ProficiencyIs100() {
    // given
    var vocab = makeVocab()
    
    // when
    vocab.increaseNumberOfCorrectAnswerByOne()
    vocab.increaseNumberOfWrongAnswerByOne()
    
    
    // then
    XCTAssertEqual(vocab.proficiency, 100)
  }
  
  func testCalculate_1TimeTestTaken_WrongAnswer_LastTimeTakenToday_ProficiencyIs0() {
    var vocab = makeVocab()
    vocab.increaseNumberOfWrongAnswerByOne()
    XCTAssertEqual(vocab.proficiency, 0)
  }
  
  // 1...6
  func testCalculate_1TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs51() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 1
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 51)
  }
  
  func testCalculate_1TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs26() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 1
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 26)
  }
  
  func testCalculate_6TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs51() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 6
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 51)
  }
  
  func testCalculate_6TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs26() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 6
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 26)
  }
  
  
  // 7...12
  func testCalculate_7TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs64() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 7
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 64)
  }
  
  func testCalculate_7TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs40() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 7
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 40)
  }
  
  func testCalculate_12TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs64() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 12
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 64)
  }
  
  func testCalculate_12TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs40() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 12
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 40)
  }
  
  // 13...18
  func testCalculate_13TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs75() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 13
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 75)
  }
  
  func testCalculate_13TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs56() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 13
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 56)
  }
  
  func testCalculate_18TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs75() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 18
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 75)
  }
  
  func testCalculate_18TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs56() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 18
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 56)
  }
  
  // 19...24
  func testCalculate_19TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs84() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 19
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 84)
  }
  
  func testCalculate_19TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs70() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 19
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 70)
  }
  
  func testCalculate_24TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs84() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 24
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 84)
  }
  
  func testCalculate_24TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs70() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 24
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 70)
  }
  
  // 25...30
  func testCalculate_25TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs91() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 25
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 91)
  }
  
  func testCalculate_25TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs82() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 25
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 82)
  }
  
  func testCalculate_30TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs91() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 30
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 91)
  }
  
  func testCalculate_30TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs82() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 30
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 82)
  }
  
  // 31...36
  func testCalculate_31TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs96() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 31
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 96)
  }
  
  func testCalculate_31TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs92() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 31
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 92)
  }
  
  func testCalculate_36TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs96() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 36
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 96)
  }
  
  func testCalculate_36TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs96() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 36
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 92)
  }
  
  // 37...42
  func testCalculate_37TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs99() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 37
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 99)
  }
  
  func testCalculate_37TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs98() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 37
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 98)
  }
  
  func testCalculate_42TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs99() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 42
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 99)
  }
  
  func testCalculate_42TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs98() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 42
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 98)
  }
  
  // 43 and 99
  func testCalculate_43TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs100() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 43
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 100)
  }
  
  func testCalculate_43TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs100() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 43
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 100)
  }
  
  func testCalculate_99TimeTestTaken_CorrectAnswer_LastTimeTest_1dayAgo_ProficiencyIs100() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 1.days - 1.seconds
    let numberOfTakenTest: UInt = 99
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 100)
  }
  
  func testCalculate_99TimeTestTaken_CorrectAnswer_LastTimeTest_2daysAgo_ProficiencyIs100() {
    var vocab = makeVocab()
    let lastTimeTest = Date() - 2.days - 1.seconds
    let numberOfTakenTest: UInt = 99
    let numberOfCorrectAnswer = numberOfTakenTest
    try? vocab.setTestTakenData(numberOfTestTaken: numberOfTakenTest,
                                                numberOfCorrectAnswer: numberOfCorrectAnswer,
                                                lastTimeTest: lastTimeTest)
    XCTAssertEqual(vocab.proficiency, 100)
  }
  
  // MARK: Helper functions
  private func makeVocab() -> Vocab {
    return Vocab(id: 0, word: "", translations: [:])
  }
}
