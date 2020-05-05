//
//  RealmDataStoreTests.swift
//  EasyKIIPKitTests
//
//  Created by Tuan on 2020/05/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import RealmSwift

struct RealmProvider {
  
  let configuration: Realm.Configuration
  
  init(config: Realm.Configuration) {
    self.configuration = config
  }
  
  var realm: Realm {
    return try! Realm(configuration: configuration)
  }
  
}

class RealmBook: Object {
  @objc dynamic var id: Int = 0
  @objc dynamic var name: String = ""
  @objc dynamic var thumbName: String?
  
  convenience init(id: Int, name: String, thumbName: String?) {
    self.init()
    self.id = id
    self.name = name
    self.thumbName = thumbName
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
}

class RealmDataStore: VocabDataStore {
  
  private let bundledRealmProvider: RealmProvider
  private let historyRealmProvider: RealmProvider
  
  init(bundled: RealmProvider, history: RealmProvider) {
    self.bundledRealmProvider = bundled
    self.historyRealmProvider = history
  }
  
  func getListOfBook() -> [Book] {
    return []
  }
  
  func getListOfLesson(in book: Book) -> [Lesson] {
    return []
  }
  
  func getListOfVocabs(in lesson: Lesson) -> [Vocab] {
    return []
  }
  
  func markVocabAsMastered(_ vocab: Vocab) {
    
  }
  
  func recordVocabPracticed(vocab: Vocab, isCorrectAnswer: Bool) {
    
  }
  
  func getVocab(by id: UInt) -> Vocab? {
    return nil
  }
  
  func searchVocab(keyword: String) -> [Vocab] {
    return []
  }
  
  func syncLessonProficiency(lessonID: UInt, proficiency: UInt8, lastTimeSynced: Double) {
    
  }
  
  func syncPracticeHistory(vocabID: UInt, isMastered: Bool, testTaken: UInt, correctAnswer: UInt, firstLearnDate: Date, lastTimeTest: Date) {
    
  }
}

class RealmDataStoreTests: XCTestCase {

  func test_initState_isVocabDataStore() {
    let sut = makeSut()
    XCTAssertNotNil(sut as? VocabDataStore)
  }
  
  func test_getListOfBook() {
    let (sut, bundledRealmProvider) = makeSut()
    
    let sampleData = makeSampleVocabsData(into: bundledRealmProvider)
    
    XCTAssertEqual(sut.getListOfBook().count, sampleData.count)
  }

  // Make sut
  private func makeSut() -> (RealmDataStore, RealmProvider) {
    let bundledConfig = makeBundledConfig()
    let bundledRealmProvider: RealmProvider = RealmProvider(config: bundledConfig)
    
    let historyConfig = makeHistoryConfig()
    let historyRealmProvider: RealmProvider = RealmProvider(config: historyConfig)
    
    let sut = RealmDataStore(bundled: bundledRealmProvider,
                             history: historyRealmProvider)
    return (sut, bundledRealmProvider)
  }
  
  // Helpers
  private func makeBundledConfig() -> Realm.Configuration {
    let bundledConfig: Realm.Configuration = Realm.Configuration(inMemoryIdentifier: "ios.realmdatastore.bundled")
    return bundledConfig
  }
  
  private func makeHistoryConfig() -> Realm.Configuration {
    let historyConfig: Realm.Configuration = Realm.Configuration(inMemoryIdentifier: "ios.realmdatastore.history")
    return historyConfig
  }
  
  private func makeSampleVocabsData(into realmProvider: RealmProvider) -> [RealmBook] {
    let book1 = RealmBook(id: 1, name: "Test 1", thumbName: nil)
    
    let realm = realmProvider.realm
    try! realm.write {
      realm.add(book1)
    }
    
    return [book1]
  }
  
}
