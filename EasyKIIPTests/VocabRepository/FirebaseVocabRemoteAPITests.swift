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
  
  private let userID = "H0NIPkDah7Vc1RkZF3TgpJ0jGsp2"
  /// Big number so that it will not affect real data
  private let bookID = 9999
  private let lessonID = 1
  
  
  func test_isVocabRemoteAPI() {
    let sut = FirebaseVocabRemoteAPI()
    XCTAssertNotNil(sut as? VocabRemoteAPI)
  }

  func test_loadLessonData_bookRemoteDataNotExisted_createRemoteBookData_returnEmpty() {
    
    let sut = FirebaseVocabRemoteAPI()
    
    let expect = expectation(description: "Return empty array")
    
    sut.loadLessonData(userID: userID, bookID: bookID) { (lessons) in
      expect.fulfill()
    }
    
    wait(for: [expect], timeout: 5)
  }
  
  func test_saveLessonHistory() {
    
    let sut = FirebaseVocabRemoteAPI()
    let firebaseLesson = makeFakeFirebaseLesson()
    
    sut.saveLessonHistory(userID: userID, bookID: bookID, lesson: firebaseLesson)
    
    let expect = expectation(description: "Return array includes firebaseLesson")
    
    sut.loadLessonData(userID: userID, bookID: bookID) { (firebaseLessons) in
      
      if firebaseLessons.contains(where: { $0.id == firebaseLesson.id }) {
        expect.fulfill()
      }
    }
    
    wait(for: [expect], timeout: 5)
    
  }
  
  private func makeFakeFirebaseLesson() -> FirebaseLesson {
    let lesson = FirebaseLesson(id: lessonID, proficiency: 80, lastTimeSynced: Date().timeIntervalSince1970)
    return lesson
  }
  
}
