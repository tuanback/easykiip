//
//  TranslationTests.swift
//  EasyKIIPKitTests
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
@testable import EasyKIIPKit

class TranslationTests: XCTestCase {

  func test_initTranslation_withLanguageCode() {
    let languageCode = LanguageCode.vi
    let translation = ""
    
    let sut = Translation(languageCode: languageCode, translation: translation)
    
    XCTAssertEqual(sut.languageCode, languageCode.rawValue)
  }
  
  func test_initTranslation_withLanguageCodeAndNotEmptyTranslation() {
    let languageCode = LanguageCode.vi
    let translation = "Translation"
    
    let sut = Translation(languageCode: languageCode, translation: translation)
    
    XCTAssertEqual(sut.translation, translation)
  }
}
