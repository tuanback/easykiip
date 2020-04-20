//
//  PraticeHistory.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

enum AppError: Error {
  case invalidData
}

public struct PracticeHistory {
  private(set) var isLearned: Bool
  private(set) var numberOfTestTaken: UInt
  private(set) var numberOfCorrectAnswer: UInt
  private(set) var numberOfWrongAnswer: UInt
  private(set) var lastTimeTest: Date
  private(set) var proficiency: UInt8
  private(set) var isMastered: Bool
  
  init() {
    self.isLearned = false
    self.numberOfTestTaken = 0
    self.numberOfCorrectAnswer = 0
    self.numberOfWrongAnswer = 0
    self.lastTimeTest = Date()
    self.proficiency = 0
    self.isMastered = false
  }
  
  /// Mark a vocab as mastered, it means, user doesn't want the app to show the vocab for practice
  mutating func markAsIsMastered() {
    self.isMastered = true
    self.isLearned = true
    self.proficiency = 100
  }
  
  mutating func increaseNumberOfCorrectAnswerByOne() {
    self.numberOfCorrectAnswer += 1
    self.numberOfTestTaken += 1
    self.lastTimeTest = Date()
  }
  
  mutating func increaseNumberOfWrongAnswerByOne() {
    self.numberOfWrongAnswer += 1
    self.numberOfTestTaken += 1
    self.lastTimeTest = Date()
  }
  
  /// Set taken test data, should be used when we want to update the test taken data that may come from different source. Number of wrong answer will be calculated based on test taken and correct answer
  /// - Parameters:
  ///   - numberOfTakenTest: number of test has been taken
  ///   - numberOfCorrectAnswer: number of correct answer
  mutating func setTestData(numberOfTestTaken: UInt,
                            numberOfCorrectAnswer: UInt) throws {
    guard numberOfTestTaken >= numberOfCorrectAnswer else {
      throw AppError.invalidData
    }
    self.numberOfTestTaken = numberOfTestTaken
    self.numberOfCorrectAnswer = numberOfCorrectAnswer
    self.numberOfWrongAnswer = numberOfTestTaken - numberOfCorrectAnswer
  }
}
