//
//  KIIPVocabRepositoryTests.swift
//  EasyKIIPKitTests
//
//  Created by Tuan on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
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
