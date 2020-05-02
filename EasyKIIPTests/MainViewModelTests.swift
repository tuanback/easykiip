//
//  MainViewModelTests.swift
//  EasyKIIPTests
//
//  Created by Tuan on 2020/05/02.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import UserSession
import EasyKIIPKit
import RxSwift
import RxTest
import RxBlocking
@testable import Easy_KIIP

class MainViewModelTests: XCTestCase {
  
  var scheduler: TestScheduler!
  var subscription: Disposable!
  
  override func setUp() {
    super.setUp()
    
    scheduler = TestScheduler(initialClock: 0)
  }
  
  override func tearDown() {
    scheduler.scheduleAt(1000) {
      self.subscription.dispose()
    }
    super.tearDown()
  }
  
  func test_getNumberOfBooks_equalToVocabRepo() {
    let (sut, _) = makeSut()
    XCTAssertEqual(sut.getNumberOfBooks(), sut.vocabRepository.getListOfBook().count)
  }
  
  func test_getBookViewModel() throws {
    let observer = scheduler.createObserver([BookItemViewModel].self)
    
    let (sut, dataStore) = makeSut()

    let correctedResult: [Recorded<Event<[BookItemViewModel]>>] = [Recorded.next(0, dataStore.getListOfBook().map(convertToItemViewModel(_:)))]
    
    self.subscription = sut.bookViewModels.subscribe(observer)
    
    scheduler.start()
    
    let results =  observer.events
    
    XCTAssertEqual(results, correctedResult)
  }
  
  private func convertToItemViewModel(books: [Book]) -> [BookItemViewModel] {
    return books.map(convertToItemViewModel(_:))
  }
  
  private func convertToItemViewModel(_ book: Book) -> BookItemViewModel {
    return BookItemViewModel(id: book.id, name: book.name, thumbURL: book.thumbURL)
  }
  
  private func makeSut() -> (MainViewModel, VocabDataStore) {
    let vocabDataStore = VocabDataStoreInMemory()
    let userSessionRepository = KIIPUserSessionRepository(dataStore: FakeUserSessionDataStore(hasToken: true), remoteAPI: FakeAuthRemoteAPI())
    let vocabRepository = KIIPVocabRepository(remoteAPI: FakeVocabRemoteAPI(), dataStore: vocabDataStore)
    
    let sut = MainViewModel(userSessionRepository: userSessionRepository, vocabRepository: vocabRepository)
    return (sut, vocabDataStore)
  }
  
}


