//
//  ReadingPartTests.swift
//  EasyKIIPKitTests
//
//  Created by Real Life Swift on 2020/04/23.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
@testable import EasyKIIPKit

class ReadingPartTests: XCTestCase {
  
  private let id: UInt = 1
  private let script: String = "안녕하세요"
  private let enTranslation: String = "Hello"
  private let viTranslation: String = "Xin chào"
  private lazy var translations: [LanguageCode: String] = [.en: enTranslation,
                                                           .vi: viTranslation]
  
  private var sut: ReadingPart!
  
  override func setUp() {
    super.setUp()
    sut = ReadingPart(id: id, script: script, translations: translations)
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
  func testInit_sets_id() {
    XCTAssertEqual(sut.id, id)
  }
  
  func testInit_sets_script() {
    XCTAssertEqual(sut.script, script)
  }
  
  func testInit_sets_translations() {
    XCTAssertEqual(sut.translations, translations)
  }
  
  func testInit_numberOfTranslations_2() {
    XCTAssertEqual(sut.translations.count, 2)
  }
  
  func testInit_viTranslation_sets() {
    XCTAssertEqual(sut.translations[.vi], viTranslation)
  }
  
  func testInit_enTranslation_sets() {
    XCTAssertEqual(sut.translations[.en], enTranslation)
  }
}
