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

public class PracticeHistory {
  private(set) var isLearned: Bool {
    didSet {
      if firstLearnDate == nil {
        firstLearnDate = Date()
      }
    }
  }
  private(set) var id: Int
  private(set) var numberOfTestTaken: Int
  private(set) var numberOfCorrectAnswer: Int
  private(set) var numberOfWrongAnswer: Int
  private(set) var firstLearnDate: Date?
  private(set) var lastTimeTest: Date?
  private(set) var isMastered: Bool
  
  init(id: Int) {
    self.id = id
    self.isLearned = false
    self.numberOfTestTaken = 0
    self.numberOfCorrectAnswer = 0
    self.numberOfWrongAnswer = 0
    self.isMastered = false
  }
  
  /// Mark a vocab as mastered, it means, user doesn't want the app to show the vocab for practice
  func markAsIsMastered() {
    self.isMastered = true
    self.isLearned = true
    self.lastTimeTest = Date()
  }
  
  func increaseNumberOfCorrectAnswerByOne() {
    self.isLearned = true
    self.numberOfCorrectAnswer += 1
    self.numberOfTestTaken += 1
    self.lastTimeTest = Date()
  }
  
  func increaseNumberOfWrongAnswerByOne() {
    self.isLearned = true
    self.numberOfWrongAnswer += 1
    self.numberOfTestTaken += 1
    self.lastTimeTest = Date()
  }
  
  /// Set taken test data, should be used when we want to update the test taken data that may come from different source. Number of wrong answer will be calculated based on test taken and correct answer
  /// - Parameters:
  ///   - numberOfTakenTest: number of test has been taken
  ///   - numberOfCorrectAnswer: number of correct answer
  func setTestTakenData(isMastered: Bool,
                        numberOfTestTaken: Int,
                        numberOfCorrectAnswer: Int,
                        firstLearnDate: Date?,
                        lastTimeTest: Date?) {
    // Only set if the is mastered equal to true
    if isMastered {
      self.isMastered = true
      self.isLearned = true
    }
    
    // If number of current test taken > input data => Synced
    guard self.numberOfTestTaken < numberOfTestTaken else { return }
    
    guard numberOfTestTaken > 0 else { return }
    
    self.numberOfTestTaken = numberOfTestTaken
    self.numberOfCorrectAnswer = (numberOfCorrectAnswer > numberOfTestTaken) ? numberOfTestTaken : numberOfCorrectAnswer
    self.numberOfWrongAnswer = numberOfTestTaken - numberOfCorrectAnswer
    self.firstLearnDate = firstLearnDate
    self.lastTimeTest = lastTimeTest
    self.isLearned = true
  }
}
