//
//  VocabTests.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
@testable import EasyKIIPKit

class VocabTests: XCTestCase {

  func test_init_vocab_withID_Word_OneTranslation_SetCorrectly() {
    let id: UInt = 1
    let word = "Word"
    let translation = Translation(languageCode: .en, translation: "Hello")
    let translations: Set<Translation> = [translation]
    let sut = Vocab(id: id, word: word, translations: translations)
    
    XCTAssertEqual(sut.id, id)
    XCTAssertEqual(sut.word, word)
    XCTAssertEqual(sut.translations.count, translations.count)
  }
  
  func test_init_vocab_withID_Word_TwoDuplicateTranslation_TranslationsCountEqualOne() {
    let id: UInt = 1
    let word = "Word"
    let translation = Translation(languageCode: .en, translation: "Hello")
    let translation2 = Translation(languageCode: .en, translation: "Hello")
    let translations: Set<Translation> = [translation, translation2]
    
    let sut = Vocab(id: id, word: word, translations: translations)
    
    XCTAssertEqual(sut.id, id)
    XCTAssertEqual(sut.word, word)
    XCTAssertEqual(sut.translations.count, 1)
  }
  
  func test_init_vocab_setPractiveHistoryLearnedValueEqualFalse() {
    let id: UInt = 1
    let word = "Word"
    let translations: Set<Translation> = []
    
    let sut = Vocab(id: id, word: word, translations: translations)
    
    XCTAssertFalse(sut.practiceHistory.isLearned)
  }
  
}
