//
//  PraticeHistory.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

struct PracticeHistory {
  var isLearned: Bool
  var numberOfTestTaken: UInt
  var numberOfCorrectAnswer: UInt
  var numberOfWrongAnswer: UInt
  var lastTimeTest: Date
  var proficiency: UInt8
  
  init() {
    self.isLearned = false
    self.numberOfTestTaken = 0
    self.numberOfCorrectAnswer = 0
    self.numberOfWrongAnswer = 0
    self.lastTimeTest = Date()
    self.proficiency = 0
  }
}
