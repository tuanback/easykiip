//
//  Lesson.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class Lesson {
  public private(set) var id: UInt
  public private(set) var name: String
  public private(set) var translations: [LanguageCode: String]
  public private(set) var readingParts: [ReadingPart]
  private(set) var vocabs: [Vocab]
  
  public var proficiency: UInt8 {
    guard vocabs.count > 0 else { return 100 }
    let total = vocabs.reduce(0) { (result, vocab) -> UInt in
      result + UInt(vocab.proficiency)
    }
    let count = UInt(vocabs.count)
    return UInt8(total / count)
  }
  public var lastTimeLeaned: Date? {
    let learnedVocabs = vocabs.filter { $0.lastTimeTest != nil }
    guard learnedVocabs.count > 0 else { return nil }
    return learnedVocabs.sorted { $0.lastTimeTest! > $1.lastTimeTest! }[0].lastTimeTest
  }
  
  init(id: UInt, name: String, translations: [LanguageCode: String], vocabs: [Vocab], readingParts: [ReadingPart]) {
    self.id = id
    self.name = name
    self.translations = translations
    self.vocabs = vocabs
    self.readingParts = readingParts
  }
  
}
