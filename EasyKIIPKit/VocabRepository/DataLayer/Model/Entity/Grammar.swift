//
//  Grammar.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/07/12.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class Grammar {
  public private(set) var name: String
  public private(set) var example: String
  public private(set) var similarGrammar: String?
  public private(set) var exampleTranslations: [LanguageCode: String]
  public private(set) var explainationTranslations: [LanguageCode: String]
  
  public init(name: String,
              example: String,
              similarGrammar: String?,
              exampleTranslations: [LanguageCode: String],
              explainationTranslations: [LanguageCode: String]) {
    self.name = name
    self.example = example
    self.similarGrammar = similarGrammar
    self.exampleTranslations = exampleTranslations
    self.explainationTranslations = explainationTranslations
  }
}
