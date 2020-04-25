//
//  LessonTests.swift
//  EasyKIIPKitTests
//
//  Created by Real Life Swift on 2020/04/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
@testable import EasyKIIPKit

class LessonTests: XCTestCase {
  
  private var sut: Lesson!
  
  private var id: UInt = 0
  private var lessionName = "Lesson"
  private var translations: [LanguageCode: String] = [.en: "Lesson", .vi: "Bài"]
  private var readingParts: [ReadingPart] = [ReadingPart(id: 0, script: "1", translations: [.en: "vi"])]
  
  func testProficiencyCalculate_VocabEmpty_Proficiency100() {
    let sut = makeSut(with: [])
    XCTAssertEqual(sut.proficiency, 100)
  }
  
  func testProficiencyCalculate_OneVocab_OneWrongAnswer_Proficiency0() throws {
    var vocab = Vocab(id: 0, word: "", translations: [:])
    try vocab.setTestTakenData(numberOfTestTaken: 1, numberOfCorrectAnswer: 0, lastTimeTest: Date())
    let sut = makeSut(with: [vocab])
    XCTAssertEqual(sut.proficiency, 0)
  }
  
  func testProficiencyCalculate_OneVocab_OneCorrectAnswer_Proficiency100() throws {
    var vocab = Vocab(id: 0, word: "", translations: [:])
    try vocab.setTestTakenData(numberOfTestTaken: 1, numberOfCorrectAnswer: 0, lastTimeTest: Date())
    let sut = makeSut(with: [vocab])
    XCTAssertEqual(sut.proficiency, 0)
  }
  
  func testProficiencyCalculate_TwoVocab_OneCorrect_OnceWrong_Proficiency50() throws {
    var vocab1 = Vocab(id: 0, word: "", translations: [:])
    try vocab1.setTestTakenData(numberOfTestTaken: 1, numberOfCorrectAnswer: 1, lastTimeTest: Date())
    var vocab2 = Vocab(id: 1, word: "", translations: [:])
    try vocab2.setTestTakenData(numberOfTestTaken: 1, numberOfCorrectAnswer: 0, lastTimeTest: Date())
    let sut = makeSut(with: [vocab1, vocab2])
    XCTAssertEqual(sut.proficiency, 50)
  }
  
  func testProficiencyCalculate_TwoVocab_TwoCorrect_Proficiency100() throws {
    var vocab1 = Vocab(id: 0, word: "", translations: [:])
    try vocab1.setTestTakenData(numberOfTestTaken: 1, numberOfCorrectAnswer: 1, lastTimeTest: Date())
    var vocab2 = Vocab(id: 1, word: "", translations: [:])
    try vocab2.setTestTakenData(numberOfTestTaken: 1, numberOfCorrectAnswer: 1, lastTimeTest: Date())
    let sut = makeSut(with: [vocab1, vocab2])
    XCTAssertEqual(sut.proficiency, 100)
  }
  
  func testProficiencyCalculate_TwoVocab_TwoWrong_Proficiency0() throws {
    var vocab1 = Vocab(id: 0, word: "", translations: [:])
    try vocab1.setTestTakenData(numberOfTestTaken: 1, numberOfCorrectAnswer: 0, lastTimeTest: Date())
    var vocab2 = Vocab(id: 1, word: "", translations: [:])
    try vocab2.setTestTakenData(numberOfTestTaken: 1, numberOfCorrectAnswer: 0, lastTimeTest: Date())
    let sut = makeSut(with: [vocab1, vocab2])
    XCTAssertEqual(sut.proficiency, 0)
  }
  
  func testProficiencyCalculate_TwoVocab_TwoMastered_Proficiency100() throws {
    var vocab1 = Vocab(id: 0, word: "", translations: [:])
    vocab1.markAsIsMastered()
    var vocab2 = Vocab(id: 1, word: "", translations: [:])
    vocab2.markAsIsMastered()
    let sut = makeSut(with: [vocab1, vocab2])
    XCTAssertEqual(sut.proficiency, 100)
  }
  
  func testLastTimeLearned() throws {
    let time1 = Date()
    var vocab1 = Vocab(id: 0, word: "", translations: [:])
    try vocab1.setTestTakenData(numberOfTestTaken: 1, numberOfCorrectAnswer: 1, lastTimeTest: time1)
    sleep(1)
    let time2 = Date()
    var vocab2 = Vocab(id: 1, word: "", translations: [:])
    try vocab2.setTestTakenData(numberOfTestTaken: 1, numberOfCorrectAnswer: 1, lastTimeTest: time2)
    let sut = makeSut(with: [vocab1, vocab2])
    XCTAssertEqual(sut.lastTimeLeaned, time2)
  }
  
  // Helper methods
  private func makeSut(with vocabs: [Vocab]) -> Lesson {
    return Lesson(id: id, name: lessionName, translations: translations, vocabs: vocabs, readingParts: readingParts)
  }
  
}
