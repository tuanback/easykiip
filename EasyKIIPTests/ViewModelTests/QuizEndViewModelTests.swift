//
//  QuizEndViewModelTests.swift
//  EasyKIIPTests
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import Firebase
@testable import Easy_KIIP

class QuizEndViewModelTests: XCTestCase {

  func test_init_withoutAd_hideAdView() {
    
    let sut = QuizEndViewModel(ad: nil)
    let adHiddenSpy = Spy<Bool>(observable: sut.oAdViewHidden.asObservable())

    XCTAssertTrue(adHiddenSpy.values.last!)
  }
  
  func test_init_withoutAd_showEndView() {
    
    let sut = QuizEndViewModel(ad: nil)
    let adHiddenSpy = Spy<Bool>(observable: sut.oEndViewHidden.asObservable())

    XCTAssertFalse(adHiddenSpy.values.last!)
  }
  
}
