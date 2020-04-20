//
//  Translation.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

struct Translation: Hashable {
  var languageCode: String
  var translation: String
  
  init(languageCode: LanguageCode, translation: String) {
    self.languageCode = languageCode.rawValue
    self.translation = translation
  }
}
