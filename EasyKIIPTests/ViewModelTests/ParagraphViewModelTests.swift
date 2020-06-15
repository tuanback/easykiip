//
//  ParagraphViewModelTests.swift
//  EasyKIIPTests
//
//  Created by Real Life Swift on 2020/06/15.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import EasyKIIPKit
@testable import Easy_KIIP

class ParagraphViewModelTests: XCTestCase {
  
  func test_init_return2ChildVC() {
    
    let readingPart = ReadingPart(
      scriptName: "korean",
      script: "korean scrip",
      scriptNameTranslation: [.vi: "vietnamese", .en: "english"],
      scriptTranslation: [.vi: "vietnamese script", .en: "english script"])
    
    let sut = ParagraphViewModel(readingPart: readingPart)

    let scriptsSpy = Spy<[Script]>(observable: sut.oScripts)
    
    let scripts = [Script(name: "korean", translation: "korean scrip"),
                   Script(name: "vietnamese", translation: "vietnamese script")]
    
    XCTAssertEqual(scriptsSpy.values.last!, scripts)
  }
  
}
