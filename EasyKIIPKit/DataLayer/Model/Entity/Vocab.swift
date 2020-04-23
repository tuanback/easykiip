//
//  Vocab.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

struct Vocab {
  private(set) var id: UInt
  private(set) var word: String
  private(set) var translations: Set<Translation>
  private(set) var practiceHistory: PracticeHistory
  var proficiency: UInt8 {
    return ProficiencyCalculator.calculate(vocab: self)
  }
  
  init(id: UInt, word: String, translations: Set<Translation>) {
    self.id = id
    self.word = word
    self.translations = translations
    self.practiceHistory = PracticeHistory()
  }
  
  mutating func markAsIsMastered() {
    self.practiceHistory.markAsIsMastered()
  }
  
  mutating func increaseNumberOfCorrectAnswerByOne() {
    self.practiceHistory.increaseNumberOfCorrectAnswerByOne()
  }
  
  mutating func increaseNumberOfWrongAnswerByOne() {
    self.practiceHistory.increaseNumberOfWrongAnswerByOne()
  }
  
  /// Set taken test data, should be used when we want to update the test taken data that may come from different source. Number of wrong answer will be calculated based on test taken and correct answer
  /// - Parameters:
  ///   - numberOfTakenTest: number of test has been taken
  ///   - numberOfCorrectAnswer: number of correct answer
  mutating func setTestTakenData(numberOfTestTaken: UInt,
                                 numberOfCorrectAnswer: UInt,
                                 lastTimeTest: Date) throws {
    try self.practiceHistory.setTestTakenData(numberOfTestTaken: numberOfTestTaken,
                                              numberOfCorrectAnswer: numberOfCorrectAnswer,
                                              lastTimeTest: lastTimeTest)
  }
}
