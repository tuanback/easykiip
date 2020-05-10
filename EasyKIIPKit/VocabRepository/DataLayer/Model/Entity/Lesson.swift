//
//  Lesson.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class Lesson {
  public private(set) var id: Int
  public private(set) var name: String
  /// To display lesson index in the book
  public private(set) var index: Int
  public private(set) var translations: [LanguageCode: String]
  public private(set) var readingParts: [ReadingPart]
  public private(set) var vocabs: [Vocab]
  
  public private(set) var proficiency: UInt8
  
  public private(set) var lastTimeLearned: Date?
  
  public init(id: Int,
              name: String,
              index: Int,
              translations: [LanguageCode: String],
              vocabs: [Vocab],
              readingParts: [ReadingPart],
              proficiency: UInt8? = nil) {
    self.id = id
    self.name = name
    self.index = index
    self.translations = translations
    self.vocabs = vocabs
    self.readingParts = readingParts
    if let proficiency = proficiency {
      self.proficiency = proficiency
    }
    else {
      self.proficiency = 0
      self.proficiency = self.calculateProficiency()
    }
  }
  
  private func calculateProficiency() -> UInt8 {
    guard vocabs.count > 0 else { return 100 }
    let total = vocabs.reduce(0) { (result, vocab) -> UInt in
      result + UInt(vocab.proficiency)
    }
    let count = UInt(vocabs.count)
    return UInt8(total / count)
  }
  
  func setProficiency(_ proficiency: UInt8) {
    self.proficiency = proficiency
  }
  
  func setLastTimeLearned(_ date: Date?) {
    self.lastTimeLearned = date
  }
  
}
