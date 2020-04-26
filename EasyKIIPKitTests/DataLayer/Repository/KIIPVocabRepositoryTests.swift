//
//  KIIPVocabRepositoryTests.swift
//  EasyKIIPKitTests
//
//  Created by Tuan on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import SwiftDate
@testable import EasyKIIPKit

class KIIPVocabRepositoryTests: XCTestCase {
  
  private lazy var dataStore = VocabDataStoreInMemory()
  
  func testGestListOfBook() {
    let sut = makeSut()
    XCTAssertEqual(sut.getListOfBook().count, dataStore.getListOfBook().count)
  }
  
  func testGetListOfLession() {
    let sut = makeSut()
    sut.getListOfBook().forEach {
      XCTAssertEqual(sut.getListOfLesson(in: $0).count, dataStore.getListOfLesson(in: $0).count)
    }
  }
  
  func testListOfVocab() {
    let sut = makeSut()
    sut.getListOfBook().forEach {
      sut.getListOfLesson(in: $0).forEach {
        XCTAssertEqual(sut.getListOfVocabs(in: $0).count, self.dataStore.getListOfVocabs(in: $0).count)
      }
    }
  }
  
  func testSearchVocabInKorean() {
    let keyword = "안녕"
    let sut = makeSut()
    let vocabs = sut.searchVocab(keyword: keyword)
    XCTAssertEqual(vocabs.count, dataStore.searchVocab(keyword: keyword).count)
  }
  
  func testSearchVocabInEnglish() {
    let keyword = "Hello"
    let sut = makeSut()
    let vocabs = sut.searchVocab(keyword: keyword)
    XCTAssertEqual(vocabs.count, dataStore.searchVocab(keyword: keyword).count)
  }
  
  func testSearchVocabInVN() {
    let keyword = "Xin"
    let sut = makeSut()
    let vocabs = sut.searchVocab(keyword: keyword)
    XCTAssertEqual(vocabs.count, dataStore.searchVocab(keyword: keyword).count)
  }
  
  func testMarkVocabAsMastered() {
    let sut = makeSut()
    sut.getListOfBook().forEach {
      sut.getListOfLesson(in: $0).forEach {
        sut.getListOfVocabs(in: $0).forEach {
          sut.markVocabAsMastered($0)
          let vocab = self.dataStore.getVocab(by: $0.id)
          XCTAssertNotNil(vocab)
          XCTAssertTrue(vocab!.practiceHistory.isMastered)
        }
      }
    }
  }
  
  func testRecorVocabPracticed() {
    let sut = makeSut()
    sut.getListOfBook().forEach {
      sut.getListOfLesson(in: $0).forEach {
        sut.getListOfVocabs(in: $0).forEach {
          sut.markVocabAsMastered($0)
          sut.recordVocabPracticed(vocab: $0, isCorrectAnswer: true)
          sut.recordVocabPracticed(vocab: $0, isCorrectAnswer: false)
          let vocab = self.dataStore.getVocab(by: $0.id)
          XCTAssertNotNil(vocab)
          XCTAssertEqual(vocab!.practiceHistory.numberOfTestTaken, 2)
          XCTAssertEqual(vocab!.practiceHistory.numberOfCorrectAnswer, 1)
          XCTAssertEqual(vocab!.practiceHistory.numberOfWrongAnswer, 1)
        }
      }
    }
  }
  
  func testSyncPracticeHistory() {
    let practiceHistory = PracticeHistory(id: 1)
    let firstDate = Date() - 3.days
    let lastDate = Date() - 2.days
    try? practiceHistory.setTestTakenData(numberOfTestTaken: 3, numberOfCorrectAnswer: 2, firstLearnDate: firstDate, lastTimeTest: lastDate)
    
    let sut = makeSut(practiceHistory: [practiceHistory])
    
    sut.syncUserData()
    let expect = expectation(description: "Practice history synced")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      if let vocab = self.dataStore.getVocab(by: 1) {
        XCTAssertEqual(vocab.practiceHistory.numberOfTestTaken, 3)
        XCTAssertEqual(vocab.practiceHistory.numberOfCorrectAnswer, 2)
        XCTAssertEqual(vocab.practiceHistory.numberOfWrongAnswer, 1)
        expect.fulfill()
      }
    }
    
    wait(for: [expect], timeout: 1)
  }
  
  func testListOfLowProficiencyVocabInBook() {
    let sut = makeSut()
    
    let book = sut.getListOfBook()[0]
    let vocabs = sut.getListOfLesson(in: book).flatMap { sut.getListOfVocabs(in: $0) }
    
    for vocab in vocabs {
      let testTaken = UInt.random(in: 0...30)
      let correctAnswer = UInt.random(in: 0...testTaken)
      
      let offsetDate = Int.random(in: 0...50)
      let date = Date() - offsetDate.days
      
      try? vocab.setTestTakenData(numberOfTestTaken: testTaken, numberOfCorrectAnswer: correctAnswer, firstLearnDate: date, lastTimeTest: date)
    }
    
    let lowProficiencyVocabs = sut.getListOfLowProficiencyVocab(in: book, upto: 5)
    
    for i in 0..<lowProficiencyVocabs.count - 1 {
      XCTAssertTrue(lowProficiencyVocabs[i].proficiency <= lowProficiencyVocabs[i + 1].proficiency)
    }
  }
  
  func testListOfLowProficiencyVocabInLesson() {
    let sut = makeSut()
    
    let book = sut.getListOfBook()[0]
    let lesson = sut.getListOfLesson(in: book)[0]
    let vocabs = sut.getListOfVocabs(in: lesson)
    
    for vocab in vocabs {
      let testTaken = UInt.random(in: 0...30)
      let correctAnswer = UInt.random(in: 0...testTaken)
      
      let offsetDate = Int.random(in: 0...50)
      let date = Date() - offsetDate.days
      
      try? vocab.setTestTakenData(numberOfTestTaken: testTaken, numberOfCorrectAnswer: correctAnswer, firstLearnDate: date, lastTimeTest: date)
    }
    
    let lowProficiencyVocabs = sut.getListOfLowProficiencyVocab(in: lesson, upto: 20)
    
    for i in 0..<lowProficiencyVocabs.count - 1 {
      XCTAssertTrue(lowProficiencyVocabs[i].practiceHistory.isLearned)
      XCTAssertTrue(lowProficiencyVocabs[i].proficiency <= lowProficiencyVocabs[i + 1].proficiency)
    }
  }
  
  func testGetNeedReviewVocabs() {
    let sut = makeSut()
    
    let book = sut.getListOfBook()[0]
    let lesson = sut.getListOfLesson(in: book)[0]
    let vocabs = sut.getListOfVocabs(in: lesson)
    
    for vocab in vocabs {
      let testTaken = UInt.random(in: 0...30)
      let correctAnswer = UInt.random(in: 0...testTaken)
      
      let firstOffsetDate = Int.random(in: 0...50)
      let lastOffsetDate = Int.random(in: 0...firstOffsetDate)
      let firstDate = Date() - firstOffsetDate.days
      let lastDate = Date() - lastOffsetDate.days
      
      try? vocab.setTestTakenData(numberOfTestTaken: testTaken, numberOfCorrectAnswer: correctAnswer, firstLearnDate: firstDate, lastTimeTest: lastDate)
    }
    
    let needReviewVocabs = sut.getNeedReviewVocabs(upto: 20)
    
    XCTAssertTrue(needReviewVocabs.count != 0)
  }
  
  // Helper methods
  private func makeSut(practiceHistory: [PracticeHistory] = []) -> KIIPVocabRepository {
    let remoteAPI = MockRemoteAPI(practiceHistory: practiceHistory)
    let sut = KIIPVocabRepository(remoteAPI: remoteAPI, dataStore: dataStore)
    return sut
  }
  
  private class MockRemoteAPI: VocabRemoteAPI {
    private let practiceHistory: [PracticeHistory]
    
    init(practiceHistory: [PracticeHistory]) {
      self.practiceHistory = practiceHistory
    }
    
    func loadPracticeHistory(completion: @escaping ([PracticeHistory]) -> (Void)) {
      completion(practiceHistory)
    }
  }

}
