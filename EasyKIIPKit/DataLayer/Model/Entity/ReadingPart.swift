//
//  ReadingPart.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/23.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class ReadingPart {
  
  public let id: UInt
  public let script: String
  public let translations: [LanguageCode: String]
  
  init(id: UInt, script: String, translations: [LanguageCode: String]) {
    self.id = id
    self.script = script
    self.translations = translations
  }
  
}
