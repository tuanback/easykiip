//
//  Vocab.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class Vocab {
  public private(set) var id: UInt
  public private(set) var word: String
  public private(set) var translations: [LanguageCode: String]
  private(set) var practiceHistory: PracticeHistory
  public var proficiency: UInt8 {
    return ProficiencyCalculator.calculate(vocab: self)
  }
  public var lastTimeTest: Date? {
    return practiceHistory.lastTimeTest
  }
  
  public init(id: UInt, word: String, translations: [LanguageCode: String]) {
    self.id = id
    self.word = word
    self.translations = translations
    // Practice history id should be same as vocab id
    self.practiceHistory = PracticeHistory(id: id)
  }
  
  func markAsIsMastered() {
    self.practiceHistory.markAsIsMastered()
  }
  
  func increaseNumberOfCorrectAnswerByOne() {
    self.practiceHistory.increaseNumberOfCorrectAnswerByOne()
  }
  
  func increaseNumberOfWrongAnswerByOne() {
    self.practiceHistory.increaseNumberOfWrongAnswerByOne()
  }
  
  /// Set taken test data, should be used when we want to update the test taken data that may come from different source. Number of wrong answer will be calculated based on test taken and correct answer
  /// - Parameters:
  ///   - numberOfTakenTest: number of test has been taken
  ///   - numberOfCorrectAnswer: number of correct answer
  func setTestTakenData(isMastered: Bool,
                        numberOfTestTaken: UInt,
                        numberOfCorrectAnswer: UInt,
                        firstLearnDate: Date?,
                        lastTimeTest: Date?) {
    self.practiceHistory.setTestTakenData(isMastered: isMastered,
                                          numberOfTestTaken: numberOfTestTaken,
                                          numberOfCorrectAnswer: numberOfCorrectAnswer,
                                          firstLearnDate: firstLearnDate,
                                          lastTimeTest: lastTimeTest)
  }
}
