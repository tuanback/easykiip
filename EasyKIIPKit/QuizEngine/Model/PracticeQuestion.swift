//
//  PracticeQuestion.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/06/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public struct PracticeQuestion: Equatable, Hashable {
  public let vocabID: Int
  public let question: String
  public let isQuestionKorean: Bool
  public let options: [String]
  public let answer: String
  
  public init(vocabID: Int,
              question: String,
              isQuestionKorean: Bool,
              options: [String],
              answer: String) {
    self.vocabID = vocabID
    self.question = question
    self.isQuestionKorean = isQuestionKorean
    self.options = options
    self.answer = answer
  }
}
