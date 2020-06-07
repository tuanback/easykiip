//
//  NewWordQuestion.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/06/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public struct NewWordQuestion: Equatable, Hashable {
  public let vocabID: Int
  public let word: String
  public let meaning: String
  
  public init(vocabID: Int, word: String, meaning: String) {
    self.vocabID = vocabID
    self.word = word
    self.meaning = meaning
  }
}
