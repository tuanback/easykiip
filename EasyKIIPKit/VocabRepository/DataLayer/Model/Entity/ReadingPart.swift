//
//  ReadingPart.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/23.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class ReadingPart {
  
  public let scriptName: String
  public let script: String
  public let scriptNameTranslation: [LanguageCode: String]
  public let scriptTranslation: [LanguageCode: String]
  
  public init(scriptName: String,
              script: String,
              scriptNameTranslation: [LanguageCode: String],
              scriptTranslation: [LanguageCode: String]) {
    self.script = script
    self.scriptName = scriptName
    self.scriptNameTranslation = scriptNameTranslation
    self.scriptTranslation = scriptTranslation
  }
  
}
