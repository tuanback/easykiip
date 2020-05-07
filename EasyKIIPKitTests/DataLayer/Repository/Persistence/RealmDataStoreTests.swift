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
  
  let lessons = List<RealmLesson>()
  
  convenience init(id: Int, name: String, thumbName: String?, lessons: [RealmLesson]) {
    self.init()
    self.id = id
    self.name = name
    self.thumbName = thumbName
    self.lessons.append(objectsIn: lessons)
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  func toBook() -> Book {
    var thumbURL: URL? = nil
    if let thumbName = self.thumbName,
      let url = Bundle(for: type(of: self)).url(forResource: thumbName, withExtension: "jpg") {
      thumbURL = url
    }
    return Book(id: UInt(id), name: name, thumbURL: thumbURL, lessons: [])
  }
}

class RealmLesson: Object {
  @objc dynamic var id: Int = 0
  @objc dynamic var name: String = ""
  @objc dynamic var index: Int = 1
  
  let translations = List<RealmTranslation>()
  let readingParts = List<RealmReadingPart>()
  let vocabs = List<RealmVocab>()
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  convenience init(id: Int, name: String, index: Int,
                   translations: [RealmTranslation],
                   readingParts: [RealmReadingPart],
                   vocabs: [RealmVocab]) {
    self.init()
    self.id = id
    self.name = name
    self.index = index
    self.translations.append(objectsIn: translations)
    self.readingParts.append(objectsIn: readingParts)
    self.vocabs.append(objectsIn: vocabs)
  }
}

class RealmTranslation: Object {
  @objc dynamic var languageCode: String = ""
  @objc dynamic var translation: String = ""
  
  convenience init(languageCode: String, translation: String) {
    self.init()
    self.languageCode = languageCode
    self.translation = translation
  }
}

class RealmReadingPart: Object {
  @objc dynamic var scriptName: String = ""
  @objc dynamic var script: String = ""
  
  let scriptNameTranslations = List<RealmTranslation>()
  let scriptTranslations = List<RealmTranslation>()
  
  convenience init(scriptName: String,
                   script: String,
                   scriptNameTranslations: [RealmTranslation],
                   scriptTranslations: [RealmTranslation]) {
    self.init()
    self.scriptName = scriptName
    self.script = script
    self.scriptNameTranslations.append(objectsIn: scriptNameTranslations)
    self.scriptTranslations.append(objectsIn: scriptNameTranslations)
  }
}

class RealmVocab: Object {
  @objc dynamic var id: Int = 0
  @objc dynamic var word: String = ""
  
  let translations = List<RealmTranslation>()
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  convenience init(id: Int, word: String, translations: [RealmTranslation]) {
    self.init()
    self.id = id
    self.word = word
    self.translations.append(objectsIn: translations)
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
    let realm = bundledRealmProvider.realm
    let realmBooks = realm.objects(RealmBook.self)
    return realmBooks.map { $0.toBook() }
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
    let (sut, _) = makeSut()
    let vocabDataStore = sut as? VocabDataStore
    XCTAssertNotNil(vocabDataStore)
  }
  
  func test_getListOfBook_numberOfBookCountEqual() {
    let (sut, bundledRealmProvider) = makeSut()
    
    let sampleData = makeSampleVocabsData(into: bundledRealmProvider)
    
    XCTAssertEqual(sut.getListOfBook().count, sampleData.count)
  }

  func test_getListOfBook_bookContentAreSame() {
    let (sut, bundledRealmProvider) = makeSut()
    
    let sampleData = makeSampleVocabsData(into: bundledRealmProvider)
    
    let returnedBooks = sut.getListOfBook().sorted { $0.id < $1.id }
    let originBooks = sampleData.sorted { $0.id < $1.id }
    
    XCTAssertEqual(returnedBooks.count, originBooks.count)
    
    for i in 0..<originBooks.count {
      if originBooks[i].id != returnedBooks[i].id ||
        originBooks[i].name != returnedBooks[i].name {
        XCTFail()
      }
    }
  }
  
  func test_getLessonOfABook_numberOfLessonEqual() {
    
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
    let translations1 = [RealmTranslation(languageCode: "en", translation: "Hello"),
                         RealmTranslation(languageCode: "vi", translation: "Xin chào")]
    let translations2 = [RealmTranslation(languageCode: "en", translation: "Thank you"),
                         RealmTranslation(languageCode: "vi", translation: "Cảm ơn")]
    let translations3 = [RealmTranslation(languageCode: "en", translation: "Yesterday"),
                         RealmTranslation(languageCode: "vi", translation: "Hôm qua")]
    let translations4 = [RealmTranslation(languageCode: "en", translation: "Today"),
                         RealmTranslation(languageCode: "vi", translation: "Hôm nay")]
    let translations5 = [RealmTranslation(languageCode: "en", translation: "Big"),
                         RealmTranslation(languageCode: "vi", translation: "To")]
    let translations6 = [RealmTranslation(languageCode: "en", translation: "Small"),
                         RealmTranslation(languageCode: "vi", translation: "Nhỏ")]
    let translations7 = [RealmTranslation(languageCode: "en", translation: "Cold"),
                         RealmTranslation(languageCode: "vi", translation: "Lạnh")]
    let translations8 = [RealmTranslation(languageCode: "en", translation: "Hot"),
                         RealmTranslation(languageCode: "vi", translation: "Nóng")]
    let translations9 = [RealmTranslation(languageCode: "en", translation: "High"),
                         RealmTranslation(languageCode: "vi", translation: "Cao")]
    let translations10 = [RealmTranslation(languageCode: "en", translation: "Low"),
                         RealmTranslation(languageCode: "vi", translation: "Thấp")]
    let translations11 = [RealmTranslation(languageCode: "en", translation: "Beautiful"),
                         RealmTranslation(languageCode: "vi", translation: "Đẹp")]
    
    let vocab1 = RealmVocab(id: 1, word: "안녕!", translations: translations1)
    let vocab2 = RealmVocab(id: 2, word: "감사합니다!", translations: translations2)
    let vocab3 = RealmVocab(id: 3, word: "어제", translations: translations3)
    let vocab4 = RealmVocab(id: 4, word: "오늘", translations: translations4)
    let vocab5 = RealmVocab(id: 5, word: "크다", translations: translations5)
    let vocab6 = RealmVocab(id: 6, word: "작다", translations: translations6)
    let vocab7 = RealmVocab(id: 7, word: "추다", translations: translations7)
    let vocab8 = RealmVocab(id: 8, word: "덥다", translations: translations8)
    let vocab9 = RealmVocab(id: 9, word: "높다", translations: translations9)
    let vocab10 = RealmVocab(id: 10, word: "낮다", translations: translations10)
    let vocab11 = RealmVocab(id: 11, word: "예쁘다", translations: translations11)
    
    let scriptNameTranslations = [RealmTranslation(languageCode: "en", translation: "Script"),
                                  RealmTranslation(languageCode: "vi", translation: "Script")]
    let scriptTranslations = [RealmTranslation(languageCode: "en", translation: "Hello"),
                              RealmTranslation(languageCode: "vi", translation: "Xin chào")]
    
    let readingPart = RealmReadingPart(scriptName: "Script", script: "안녕하세요~", scriptNameTranslations: scriptNameTranslations, scriptTranslations: scriptTranslations)
    
    let lesson1Trans = [RealmTranslation(languageCode: "en", translation: "Lesson 1"),
                        RealmTranslation(languageCode: "vi", translation: "Bải 1")]
    let lesson2Trans = [RealmTranslation(languageCode: "en", translation: "Lesson 2"),
                        RealmTranslation(languageCode: "vi", translation: "Bải 2")]
    let lesson3Trans = [RealmTranslation(languageCode: "en", translation: "Lesson 3"),
                        RealmTranslation(languageCode: "vi", translation: "Bải 3")]
    let lesson4Trans = [RealmTranslation(languageCode: "en", translation: "Lesson 4"),
                        RealmTranslation(languageCode: "vi", translation: "Bải 4")]
    let lesson5Trans = [RealmTranslation(languageCode: "en", translation: "Lesson 5"),
                        RealmTranslation(languageCode: "vi", translation: "Bải 5")]
    
    let lesson1 = RealmLesson(id: 1, name: "제1과 1", index: 1, translations: lesson1Trans, readingParts: [readingPart], vocabs: [vocab1, vocab2, vocab3, vocab4, vocab5, vocab6, vocab7, vocab8, vocab9, vocab10, vocab11])
    let lesson2 = RealmLesson(id: 2, name: "제1과 2", index: 2, translations: lesson2Trans, readingParts: [], vocabs: [])
    let lesson3 = RealmLesson(id: 3, name: "제1과 3", index: 3, translations: lesson3Trans, readingParts: [], vocabs: [])
    let lesson4 = RealmLesson(id: 4, name: "제1과 4", index: 4, translations: lesson4Trans, readingParts: [], vocabs: [])
    let lesson5 = RealmLesson(id: 5, name: "제1과 5", index: 5, translations: lesson5Trans, readingParts: [], vocabs: [])
    
    let book1 = RealmBook(id: 1, name: "한국어와 한국문화\n 기조", thumbName: nil, lessons: [lesson1, lesson2, lesson3, lesson4, lesson5])
    let book2 = RealmBook(id: 2, name: "한국어와 한국문화\n조급 1", thumbName: nil, lessons: [])
    let book3 = RealmBook(id: 3, name: "한국어와 한국문화\n조급 2", thumbName: nil, lessons: [])
    let book4 = RealmBook(id: 4, name: "한국어와 한국문화\n중급 1", thumbName: nil, lessons: [])
    let book5 = RealmBook(id: 5, name: "한국어와 한국문화\n중급 2", thumbName: nil, lessons: [])
    let book6 = RealmBook(id: 6, name: "한국사회 이해\n기본", thumbName: nil, lessons: [])
    let book7 = RealmBook(id: 7, name: "한국사회 이해\n심화", thumbName: nil, lessons: [])
    
    let realm = realmProvider.realm
    try! realm.write {
      realm.add(book1)
      realm.add(book2)
      realm.add(book3)
      realm.add(book4)
      realm.add(book5)
      realm.add(book6)
      realm.add(book7)
    }
    
    return [book1, book2, book3, book4, book5, book6, book7]
  }
  
}
