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
  
  private let testTaken = 99
  private let correct = 83
  
  func test_isVocabRemoteAPI() {
    let sut = FirebaseVocabRemoteAPI()
    XCTAssertNotNil(sut as? VocabRemoteAPI)
  }

  func test_loadLessonData_bookRemoteDataNotExisted_createRemoteBookData_returnEmpty() {
    
    let sut = FirebaseVocabRemoteAPI()
    
    let expect = expectation(description: "Return empty array")
    
    sut.loadLessonData(userID: userID, bookID: bookID) { (lessons) in
      if lessons.count > 0 {
        expect.fulfill()
      }
    }
    
    wait(for: [expect], timeout: 5)
  }
  
  func test_loadVocabData() {
    
    let sut = FirebaseVocabRemoteAPI()
    
    let expect = expectation(description: "Return not nill array")
    
    sut.loadVocabData(userID: userID, bookID: bookID, lessonID: lessonID) { (vocabs) in
      if vocabs.count > 0 {
        expect.fulfill()
      }
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
  
  func test_saveVocabsHistory() {
    
    let sut = FirebaseVocabRemoteAPI()
    let firebaseVocabs = makeFirebaseVocabs()
    
    sut.saveVocabHistory(userID: userID, bookID: bookID, lessonID: lessonID, vocabs: firebaseVocabs)
    
    let expect = expectation(description: "Return array includes firebaseLesson")
    
    sut.loadVocabData(userID: userID, bookID: bookID, lessonID: lessonID) { (vocabs) in
      
      if vocabs.count > 0 {
        expect.fulfill()
      }
    }
    
    wait(for: [expect], timeout: 5)
  }
  
  private func makeFakeFirebaseLesson() -> FirebaseLesson {
    let lesson = FirebaseLesson(id: lessonID, proficiency: 80, lastTimeSynced: Date().timeIntervalSince1970)
    return lesson
  }
  
  private func makeFirebaseVocabs() -> [FirebaseVocab] {
    var vocabs: [FirebaseVocab] = []
    
    for i in 1...5 {
      let isLearned = (i % 2 == 0) ? true : false
      let isMastered = (i % 3 == 0) ? true : false
      
      let vocab = FirebaseVocab(id: i,
                                isLearned: isLearned,
                                isMastered: isMastered,
                                testTaken: isLearned ? testTaken - i : 0,
                                correctAnswer: isLearned ? correct - i : 0,
                                firstTimeLearned: isLearned ? Date().timeIntervalSince1970 : nil,
                                lastTimeLearned: isLearned ? Date().timeIntervalSince1970 : nil)
      vocabs.append(vocab)
    }
    return vocabs
  }
  
}
