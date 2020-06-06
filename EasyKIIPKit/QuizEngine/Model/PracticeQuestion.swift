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
  public let options: [String]
  public let answer: String
}
