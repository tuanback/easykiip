//
//  Vocab.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

struct Vocab {
  var id: UInt
  var word: String
  var translations: Set<Translation>
  var practiceHistory: PracticeHistory
  
  init(id: UInt, word: String, translations: Set<Translation>) {
    self.id = id
    self.word = word
    self.translations = translations
    self.practiceHistory = PracticeHistory()
  }
}
