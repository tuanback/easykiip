//
//  FirebaseVocabRemoteAPITests.swift
//  EasyKIIPKitTests
//
//  Created by Tuan on 2020/05/10.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import EasyKIIPKit

class FirebaseVocabRemoteAPITests: XCTestCase {

  func test_isVocabRemoteAPI() {
    let sut = FirebaseVocabRemoteAPI()
    XCTAssertNotNil(sut as? VocabRemoteAPI)
  }

  func test_loadLessonData_bookRemoteDataNotExisted_createRemoteBookData() {
    
    
  }
  
  
  
}
