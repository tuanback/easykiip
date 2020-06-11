//
//  KIIPVocabRepositoryTests.swift
//  EasyKIIPKitTests
//
//  Created by Tuan on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import SwiftDate
import UserSession
import RxSwift
import RxTest
@testable import EasyKIIPKit

extension Lesson: Equatable {
  public static func == (lhs: Lesson, rhs: Lesson) -> Bool {
    return lhs.id == rhs.id && lhs.proficiency == rhs.proficiency
  }
}

extension Vocab: Equatable {
  public static func == (lhs: Vocab, rhs: Vocab) -> Bool {
    if lhs.id == rhs.id &&
      lhs.practiceHistory.isMastered == rhs.practiceHistory.isMastered &&
      lhs.practiceHistory.numberOfTestTaken == rhs.practiceHistory.numberOfTestTaken &&
      lhs.practiceHistory.numberOfCorrectAnswer == rhs.practiceHistory.numberOfCorrectAnswer &&
      lhs.proficiency == rhs.proficiency {
      return true
    }
    return false
  }
}

class KIIPVocabRepositoryTests: XCTestCase {
  
  private var scheduler: TestScheduler!
  private var subscription: Disposable!
  private let disposeBag = DisposeBag()
  
  override func setUp() {
    super.setUp()
    scheduler = TestScheduler(initialClock: 0)
  }
  
  override func tearDown() {
    scheduler.scheduleAt(1000) {
      self.subscription?.dispose()
    }
  }
  
  func test_getListOfBooks_dataStoreFuncCalled() {
    let (sut, _, dataStore) = makeSut()
    let _ = sut.getListOfBook()
    XCTAssertTrue(dataStore.isGetListOfBooksCalled)
  }
  
  func test_getListOfLesson_apiFuncCalled_dataStoreFuncCalled() {
    let observer = scheduler.createObserver([Lesson].self)
    
    let (sut, remoteAPI, dataStore) = makeSut()
    let book = dataStore.book
    let observable = sut.getListOfLesson(inBook: book.id)
    
    subscription = observable.subscribe(observer)
    
    scheduler.start()
    
    XCTAssertTrue(remoteAPI.isLoadLessonsCalled && dataStore.isGetLessonsCalled)
  }
  
  func test_getListOfLesson_remoteAPIReturnEmpty_getLocalLessons() {
    
    let observer = scheduler.createObserver([Lesson].self)
    
    let (sut, remoteAPI, dataStore) = makeSut()
    let book = dataStore.book
    let observable = sut.getListOfLesson(inBook: book.id)
    
    subscription = observable.subscribe(observer)
    
    scheduler.scheduleAt(500) {
      remoteAPI.loadLessonCompletion?([])
    }
    
    scheduler.start()
    
    let results = observer.events.compactMap { $0.value.element }
    
    XCTAssertEqual(results, [book.lessons])
  }
  
  func test_getListOfLesson_remoteAPIReturnData_dataStoreSyncFuncCalled() {
    let observer = scheduler.createObserver([Lesson].self)
    
    let (sut, remoteAPI, dataStore) = makeSut()
    let book = dataStore.book
    let observable = sut.getListOfLesson(inBook: book.id)
    
    subscription = observable.subscribe(observer)
    
    scheduler.scheduleAt(500) {
      let firebaseLesson = self.makeFakeFirebaseLesson()
      remoteAPI.loadLessonCompletion?([firebaseLesson])
    }
    
    scheduler.start()
    
    let results = observer.events.compactMap { $0.value.element }
    
    XCTAssertTrue(dataStore.isSyncedLessonCalled)
    XCTAssertEqual(results.count, 1)
  }
  
  func test_getLesson_getListOfVocabCalled() {
    
    let (sut, remoteAPI, dataStore) = makeSut()
    let book = dataStore.book
    let lesson = dataStore.lesson
    sut.getLesson(inBook: book.id, lessonID: lesson.id)
      .subscribe(onNext: { lesson in
        XCTAssertTrue(remoteAPI.isLoadVocabCalled)
      })
      .dispose()
    
    XCTAssertTrue(dataStore.isGetVocabsCalled)
    
  }
  
  func test_getListOfVocab_apiFuncCalled_dataStoreFuncCalled() {
    let (sut, remoteAPI, dataStore) = makeSut()
    let book = dataStore.book
    let lesson = dataStore.lesson
    
    sut.getListOfVocabs(inBook: book.id, inLesson: lesson.id)
      .subscribe(onNext: { vocabs in
        XCTAssertTrue(remoteAPI.isLoadVocabCalled)
      })
      .dispose()
    
    XCTAssertTrue(dataStore.isGetVocabsCalled)
  }
  
  func test_getListOfVocab_remoteAPIReturnEmpty_getLocalLessons() {
    
    let observer = scheduler.createObserver([Vocab].self)
    
    let (sut, remoteAPI, dataStore) = makeSut()
    let book = dataStore.book
    let lesson = dataStore.lesson
    let observable = sut.getListOfVocabs(inBook: book.id, inLesson: lesson.id)
    
    subscription = observable.subscribe(observer)
    
    scheduler.scheduleAt(500) {
      remoteAPI.loadVocabCompletion?([])
    }
    
    scheduler.start()
    
    let results = observer.events.compactMap { $0.value.element }
    
    XCTAssertEqual(results, [lesson.vocabs])
  }
  
  func test_getListOfVocab_lessonIsNotSynced_remoteAPIReturnData_dataStoreSyncFuncCalled() {
    let observer = scheduler.createObserver([Vocab].self)
    
    let (sut, remoteAPI, dataStore) = makeSut()
    let book = dataStore.book
    let lesson = dataStore.lesson
    dataStore.setLessonSyncedValue(false)
    
    let observable = sut.getListOfVocabs(inBook: book.id, inLesson: lesson.id)
    
    subscription = observable.subscribe(observer)
    
    scheduler.scheduleAt(500) {
      let firebaseVocab = self.makeFakeFirebaseVocab()
      remoteAPI.loadVocabCompletion?([firebaseVocab])
    }
    
    scheduler.start()
    
    let results = observer.events.compactMap { $0.value.element }
    
    XCTAssertTrue(dataStore.isSyncedVocabCalled)
    XCTAssertEqual(results.count, 1)
  }
  
  func test_getListOfVocab_lessonIsSynced_dataStoreSyncFuncNotCalled() {
    let observer = scheduler.createObserver([Vocab].self)
    
    let (sut, remoteAPI, dataStore) = makeSut()
    let book = dataStore.book
    let lesson = dataStore.lesson
    dataStore.setLessonSyncedValue(true)
    
    let observable = sut.getListOfVocabs(inBook: book.id, inLesson: lesson.id)
    
    subscription = observable.subscribe(observer)
    
    scheduler.scheduleAt(500) {
      let firebaseVocab = self.makeFakeFirebaseVocab()
      remoteAPI.loadVocabCompletion?([firebaseVocab])
    }
    
    scheduler.start()
    
    let results = observer.events.compactMap { $0.value.element }
    
    XCTAssertFalse(dataStore.isSyncedVocabCalled)
    XCTAssertEqual(results, [lesson.vocabs])
  }
  
  func test_searchVocab_dataStoreSeachFuncCalled() {
    let keyword = "안녕"
    let (sut, _, dataStore) = makeSut()
    let _ = sut.searchVocab(keyword: keyword)
    XCTAssertTrue(dataStore.isSearchVocabCalled)
  }
  
  func test_markVocabAsMasteredCalled() {
    let (sut, _, dataStore) = makeSut()
    let vocab = dataStore.vocab
    let _ = sut.markVocabAsMastered(vocabID: vocab.id)
    XCTAssertTrue(dataStore.isMarkVocabAsMasteredCalled)
  }
  
  func test_recordVocabPracticedCalled() {
    let (sut, _, dataStore) = makeSut()
    let vocab = dataStore.vocab
    let _ = sut.recordVocabPracticed(vocabID: vocab.id, isCorrectAnswer: true)
    XCTAssertTrue(dataStore.isRecordVocabPracticedCalled)
  }
  
  func testListOfLowProficiencyVocabInBook() {
    let (sut, _, dataStore) = makeSut()
    
    let book = dataStore.book
    let vocabs = dataStore.lesson.vocabs
    
    for vocab in vocabs {
      let testTaken = Int.random(in: 0...30)
      let correctAnswer = Int.random(in: 0...testTaken)
      
      let offsetDate = Int.random(in: 0...50)
      let date = Date() - offsetDate.days
      
      let isMastered = Bool.random()
      
      vocab.setTestTakenData(isMastered: isMastered, numberOfTestTaken: testTaken, numberOfCorrectAnswer: correctAnswer, firstLearnDate: date, lastTimeTest: date)
    }
    
    let lowProficiencyVocabs = sut.getListOfLowProficiencyVocab(inBook: book.id, upto: 5)
    
    for i in 0..<lowProficiencyVocabs.count - 1 {
      XCTAssertTrue(lowProficiencyVocabs[i].proficiency <= lowProficiencyVocabs[i + 1].proficiency)
    }
  }
  
  func testListOfLowProficiencyVocabInLesson() {
    let (sut, _, dataStore) = makeSut()
    
    let lesson = dataStore.lesson
    let vocabs = dataStore.lesson.vocabs
    
    for vocab in vocabs {
      let testTaken = Int.random(in: 0...30)
      let correctAnswer = Int.random(in: 0...testTaken)
      
      let offsetDate = Int.random(in: 0...50)
      let date = Date() - offsetDate.days
      
      let isMastered = Bool.random()
      
      vocab.setTestTakenData(isMastered: isMastered,
                             numberOfTestTaken: testTaken,
                             numberOfCorrectAnswer: correctAnswer,
                             firstLearnDate: date,
                             lastTimeTest: date)
    }
    
    let lowProficiencyVocabs = sut.getListOfLowProficiencyVocab(inLesson: lesson.id, upto: 20)
    
    for i in 0..<lowProficiencyVocabs.count - 1 {
      XCTAssertTrue(lowProficiencyVocabs[i].practiceHistory.isLearned)
      XCTAssertTrue(lowProficiencyVocabs[i].proficiency <= lowProficiencyVocabs[i + 1].proficiency)
    }
  }
  
  func testGetNeedReviewVocabs() {
    let (sut, _, dataStore) = makeSut()
    
    let vocabs = dataStore.lesson.vocabs
    
    for vocab in vocabs {
      let testTaken = Int.random(in: 0...30)
      let correctAnswer = Int.random(in: 0...testTaken)
      
      let firstOffsetDate = Int.random(in: 0...50)
      let lastOffsetDate = Int.random(in: 0...firstOffsetDate)
      let firstDate = Date() - firstOffsetDate.days
      let lastDate = Date() - lastOffsetDate.days
      
      let isMastered = Bool.random()
      
      vocab.setTestTakenData(isMastered: isMastered,
                             numberOfTestTaken: testTaken,
                             numberOfCorrectAnswer: correctAnswer,
                             firstLearnDate: firstDate,
                             lastTimeTest: lastDate)
    }
    
    let needReviewVocabs = sut.getNeedReviewVocabs(upto: 20)
    
    XCTAssertTrue(needReviewVocabs.count != 0)
  }
  
  func test_saveLessonPracticeHistory_allVocabSynced_remoteSaveFuncNotCalled() {
    let (sut, remoteAPI, dataStore) = makeSut()
    
    let book = dataStore.book
    let lesson = dataStore.lesson
    
    dataStore.setNotSyncedVocabsValue(false)
    sut.saveLessonPracticeHistory(inBook: book.id, lessonID: lesson.id)
    
    XCTAssertFalse(remoteAPI.isSaveLessonPracticeHistoryCalled)
    XCTAssertFalse(remoteAPI.isSaveVocabPracticeHistoryCalled)
  }
  
  func test_saveLessonPracticeHistory_vocabNotSynced_remoteSaveFuncCalled() {
    let (sut, remoteAPI, dataStore) = makeSut()
    
    let book = dataStore.book
    let lesson = dataStore.lesson
    let vocab = dataStore.vocab
    
    sut.recordVocabPracticed(vocabID: vocab.id, isCorrectAnswer: true)
    
    dataStore.setNotSyncedVocabsValue(true)
    sut.saveLessonPracticeHistory(inBook: book.id, lessonID: lesson.id)
    
    XCTAssertTrue(remoteAPI.isSaveLessonPracticeHistoryCalled)
    XCTAssertTrue(remoteAPI.isSaveVocabPracticeHistoryCalled)
  }
  
  func test_getRandomVocabs_numberOfVocabs1_return1RandomVocab() {
    
    let (sut, _, dataStore) = makeSut()
    
    let lesson = dataStore.lesson
    let vocabs = Array(lesson.vocabs.prefix(5))
    let vocabIDs = vocabs.map { $0.id }
    
    let _ = sut.getRandomVocabs(differentFromVocabIDs: vocabIDs, upto: 1)
    
    XCTAssertTrue(dataStore.isGetRandomVocabsCalled)
  }
  
  // Helper methods
  private func makeSut(practiceHistory: [PracticeHistory] = []) -> (KIIPVocabRepository, MockRemoteAPI, VocabDataStoreStub) {
    let fakeUserSessionDatastore = FakeUserSessionDataStore(hasToken: true)
    let remoteAPI = MockRemoteAPI(practiceHistory: practiceHistory)
    let (books, book, _, lesson, _, vocab) = makeSampleBook()
    let dataStore = VocabDataStoreStub(books: books,
                                       hasSampleDataBook: book,
                                       hasSampleDataLesson: lesson,
                                       hasSampleDataVocab: vocab)
    let userSessionRepo = KIIPUserSessionRepository(dataStore: fakeUserSessionDatastore, remoteAPI: FakeAuthRemoteAPI())
    
    let sut = KIIPVocabRepository(userSessionRepo: userSessionRepo, remoteAPI: remoteAPI, dataStore: dataStore)
    return (sut, remoteAPI, dataStore)
  }
  
  private class MockRemoteAPI: VocabRemoteAPI {
    private let practiceHistory: [PracticeHistory]
    
    private(set) var isLoadLessonsCalled = false
    private(set) var isLoadVocabCalled = false
    private(set) var isSaveLessonPracticeHistoryCalled = false
    private(set) var isSaveVocabPracticeHistoryCalled = false
    
    private(set) var loadLessonCompletion: (([FirebaseLesson])->())?
    private(set) var loadVocabCompletion: (([FirebaseVocab])->())?
    
    init(practiceHistory: [PracticeHistory]) {
      self.practiceHistory = practiceHistory
    }
    
    func loadLessonData(userID: String, bookID: Int, completion: @escaping ([FirebaseLesson]) -> ()) {
      isLoadLessonsCalled = true
      loadLessonCompletion = completion
    }
    
    func loadVocabData(userID: String, bookID: Int, lessonID: Int, completion: @escaping ([FirebaseVocab]) -> ()) {
      isLoadVocabCalled = true
      loadVocabCompletion = completion
    }
    
    func saveLessonHistory(userID: String, bookID: Int, lesson: FirebaseLesson) {
      isSaveLessonPracticeHistoryCalled = true
    }
    
    func saveVocabHistory(userID: String, bookID: Int, lessonID: Int, vocabs: [FirebaseVocab]) {
      isSaveVocabPracticeHistoryCalled = true
    }
  }
  
  private class VocabDataStoreStub: VocabDataStore {
    
    let books: [Book]
    /// This book contains sample data
    let book: Book
    /// This lesson contains sample data
    let lesson: Lesson
    /// This vocab containes sample data
    let vocab: Vocab
    
    private(set) var isSearchVocabCalled = false
    private(set) var isGetListOfBooksCalled = false
    private(set) var isGetLessonsCalled = false
    private(set) var isGetVocabsCalled = false
    private(set) var isMarkVocabAsMasteredCalled = false
    private(set) var isRecordVocabPracticedCalled = false
    private(set) var isSyncedLessonCalled = false
    private(set) var isSyncedVocabCalled = false
    private(set) var setLessonSynced = false
    
    private(set) var isLessonSynced = false
    private(set) var isGetRandomVocabsCalled = false
    
    private var notSyncedVocabs: [Vocab] = []
    
    init(books: [Book],
         hasSampleDataBook: Book,
         hasSampleDataLesson: Lesson,
         hasSampleDataVocab: Vocab) {
      self.books = books
      self.book = hasSampleDataBook
      self.lesson = hasSampleDataLesson
      self.vocab = hasSampleDataVocab
    }
    
    func getListOfBook() -> [Book] {
      isGetListOfBooksCalled = true
      return books
    }
    
    func getListOfLesson(inBook id: Int) -> [Lesson] {
      isGetLessonsCalled = true
      return book.lessons
    }
    
    func getListOfVocabs(inLesson id: Int) -> [Vocab] {
      isGetVocabsCalled = true
      return lesson.vocabs
    }
    
    func markVocabAsMastered(vocabID id: Int) {
      isMarkVocabAsMasteredCalled = true
      vocab.markAsIsMastered()
    }
    
    func recordVocabPracticed(vocabID: Int, isCorrectAnswer: Bool) {
      isRecordVocabPracticedCalled = true
      isCorrectAnswer ? vocab.increaseNumberOfCorrectAnswerByOne() : vocab.increaseNumberOfWrongAnswerByOne()
    }
    
    func getVocab(by id: Int) -> Vocab? {
      let vocabs = books.flatMap { $0.lessons }.flatMap { $0.vocabs }
      return vocabs.first { $0.id == id }
    }
    
    func searchVocab(keyword: String) -> [Vocab] {
      isSearchVocabCalled = true
      return []
    }
    
    func syncLessonProficiency(lessonID: Int, proficiency: UInt8, lastTimeSynced: Double) {
      isSyncedLessonCalled = true
    }
    
    func syncPracticeHistory(vocabID: Int, isMastered: Bool, testTaken: Int, correctAnswer: Int, firstLearnDate: Date?, lastTimeTest: Date?) {
      isSyncedVocabCalled = true
    }
    
    func isLessonSynced(_ lessonID: Int) -> Bool {
      return isLessonSynced
    }
    
    func setLessonSyncedValue(_ value: Bool) {
      isLessonSynced = value
    }
    
    func getLesson(by id: Int) -> Lesson? {
      return lesson
    }
    
    func setLessonSynced(lessonID: Int, lastTimeSynced: Double) {
      setLessonSynced = true
    }
    
    func getNotSyncedVocabsInLesson(lessonID: Int) -> [Vocab] {
      return notSyncedVocabs
    }
    
    func setNotSyncedVocabsValue(_ value: Bool) {
      if value {
        notSyncedVocabs = [vocab]
      }
      else {
        notSyncedVocabs = []
      }
    }
    
    func getRandomVocabs(differentFromVocabIDs: [Int], upto numberOfVocabs: Int) -> [Vocab] {
      isGetRandomVocabsCalled = true
      return []
    }
    
  }
  
  // Sample book
  private func makeSampleBook() -> ([Book], Book, [Lesson], Lesson, [Vocab], Vocab) {
    let vocab1 = Vocab(id: 1, word: "안녕!", translations: [.en: "Hello", .vi: "Xin chào"])
    let vocab2 = Vocab(id: 2, word: "감사합니다!", translations: [.en: "Thank you", .vi: "Cảm ơn"])
    let vocab3 = Vocab(id: 3, word: "어제", translations: [.en: "Yesterday", .vi: "Hôm qua"])
    let vocab4 = Vocab(id: 4, word: "오늘", translations: [.en: "Today", .vi: "Hôm nay"])
    let vocab5 = Vocab(id: 5, word: "크다", translations: [.en: "Big", .vi: "To"])
    let vocab6 = Vocab(id: 6, word: "작다", translations: [.en: "Small", .vi: "Nhỏ"])
    let vocab7 = Vocab(id: 7, word: "추다", translations: [.en: "Cold", .vi: "Lạnh"])
    let vocab8 = Vocab(id: 8, word: "덥다", translations: [.en: "Hot", .vi: "Nóng"])
    let vocab9 = Vocab(id: 9, word: "높다", translations: [.en: "High", .vi: "Cao"])
    let vocab10 = Vocab(id: 10, word: "낮다", translations: [.en: "Low", .vi: "Thấp"])
    let vocab11 = Vocab(id: 11, word: "예쁘다", translations: [.en: "Beautiful", .vi: "Đẹp"])
    
    
    let readingPart = ReadingPart(scriptName: "Name", script: "안녕하세요~", scriptNameTranslation: [.en: "Hello", .vi: "Xin chào"], scriptTranslation: [.en: "Hello", .vi: "Xin chào"])
    
    let vocabs = [vocab1, vocab2, vocab3, vocab4, vocab5, vocab6, vocab7, vocab8, vocab9, vocab10, vocab11]
    
    let lesson1 = Lesson(id: 1, name: "제1과 1", index: 1, translations: [.en: "Lesson 1", .vi: "Bải 1"], vocabs: vocabs, readingParts: [readingPart])
    let lesson2 = Lesson(id: 2, name: "제1과 2", index: 2, translations: [.en: "Lesson 2", .vi: "Bải 2"], vocabs: [], readingParts: [])
    let lesson3 = Lesson(id: 3, name: "제1과 3", index: 3, translations: [.en: "Lesson 3", .vi: "Bải 3"], vocabs: [], readingParts: [])
    let lesson4 = Lesson(id: 4, name: "제1과 4", index: 4, translations: [.en: "Lesson 4", .vi: "Bải 4"], vocabs: [], readingParts: [])
    let lesson5 = Lesson(id: 5, name: "제1과 5", index: 5, translations: [.en: "Lesson 5", .vi: "Bải 5"], vocabs: [], readingParts: [])
    
    let lessons = [lesson1, lesson2, lesson3, lesson4, lesson5]
    
    let book = Book(id: 1, name: "한국어와 한국문화\n 기조", thumbURL: nil, lessons: lessons)
    let book2 = Book(id: 2, name: "한국어와 한국문화\n조급 1", thumbURL: nil, lessons: [])
    let book3 = Book(id: 3, name: "한국어와 한국문화\n조급 2", thumbURL: nil, lessons: [])
    let book4 = Book(id: 4, name: "한국어와 한국문화\n중급 1", thumbURL: nil, lessons: [])
    let book5 = Book(id: 5, name: "한국어와 한국문화\n중급 2", thumbURL: nil, lessons: [])
    let book6 = Book(id: 6, name: "한국사회 이해\n기본", thumbURL: nil, lessons: [])
    let book7 = Book(id: 7, name: "한국사회 이해\n심화", thumbURL: nil, lessons: [])
    
    let books = [book, book2, book3, book4, book5, book6, book7]
    
    return (books, book, lessons, lesson1, vocabs, vocab1)
  }
  
  private func makeFakeFirebaseLesson() -> FirebaseLesson {
    return FirebaseLesson(id: 1, proficiency: 50, lastTimeSynced: Date().timeIntervalSince1970)
  }
  
  private func makeFakeFirebaseVocab() -> FirebaseVocab {
    return FirebaseVocab(id: 1, isLearned: true, isMastered: true, testTaken: 10, correctAnswer: 8, firstTimeLearned: Date().timeIntervalSince1970, lastTimeLearned: Date().timeIntervalSince1970)
  }
}
