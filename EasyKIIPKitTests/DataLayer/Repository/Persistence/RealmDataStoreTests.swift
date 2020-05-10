//
//  RealmDataStoreTests.swift
//  EasyKIIPKitTests
//
//  Created by Tuan on 2020/05/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftDate

@testable import EasyKIIPKit

class RealmDataStoreTests: XCTestCase {
  
  private var bundledRealmProvider: RealmProvider!
  private var historyRealmProvider: RealmProvider!
  private var sut: RealmDataStore!
  
  private let testTaken = 10
  private let correctAnswer = 8
  private let firstLearnDate = Date() - 5.days - 2.hours
  private let lastTimeTest = Date() - 2.days - 5.hours
  
  override func setUp() {
    super.setUp()
    
    let bundledConfig = makeBundledConfig()
    bundledRealmProvider = RealmProvider(config: bundledConfig)
    
    let historyConfig = makeHistoryConfig()
    historyRealmProvider = RealmProvider(config: historyConfig)
    
    sut = RealmDataStore(bundled: bundledRealmProvider,
                         history: historyRealmProvider)
  }
  
  override func tearDown() {
    let bundleRealm = bundledRealmProvider.realm
    try! bundleRealm.write {
      bundleRealm.deleteAll()
    }
    
    let historyRealm = historyRealmProvider.realm
    try! historyRealm.write {
      historyRealm.deleteAll()
    }
  }
  
  func test_getListOfBook_numberOfBookCountEqual() {
    let (books, _, _, _, _, _) = makeSampleVocabsData(into: bundledRealmProvider)
    
    XCTAssertEqual(sut.getListOfBook().count, books.count)
  }
  
  func test_getListOfBook_bookContentAreSame() {
    let (books, _, _, _, _, _) = makeSampleVocabsData(into: bundledRealmProvider)
    
    let returnedBooks = sut.getListOfBook().sorted { $0.id < $1.id }
    let originBooks = books.sorted { $0.id < $1.id }
    
    XCTAssertEqual(returnedBooks.count, originBooks.count)
    
    for i in 0..<originBooks.count {
      if originBooks[i].id != returnedBooks[i].id ||
        originBooks[i].name != returnedBooks[i].name {
        XCTFail()
      }
    }
  }
  
  func test_getLessonOfABook_numberOfLessonEqual() {
    let (_, book, lessons, _, _, _) = makeSampleVocabsData(into: bundledRealmProvider)
    
    XCTAssertEqual(sut.getListOfLesson(in: book.toBook()).count, lessons.count)
  }
  
  func test_getListOfLesson_lessonContentAreSame() {
    let (_, book, lessons, _, _, _) = makeSampleVocabsData(into: bundledRealmProvider)
    
    let returnedLessons = sut.getListOfLesson(in: book.toBook()).sorted { $0.id < $1.id }
    let originLessons = lessons.sorted { $0.id < $1.id }
    
    XCTAssertEqual(originLessons.count, returnedLessons.count)
    for i in 0..<originLessons.count {
      if originLessons[i].id != returnedLessons[i].id ||
        originLessons[i].name != returnedLessons[i].name ||
        originLessons[i].index != returnedLessons[i].index ||
        originLessons[i].translations.count != returnedLessons[i].translations.count ||
        originLessons[i].readingParts.count != returnedLessons[i].readingParts.count ||
        originLessons[i].vocabs.count != returnedLessons[i].vocabs.count {
        XCTFail()
      }
    }
  }
  
  func test_getListVocabOfALesson_numberOfVocabEqual() {
    let (_, _, _, lesson, vocabs, _) = makeSampleVocabsData(into: bundledRealmProvider)
    
    XCTAssertEqual(sut.getListOfVocabs(in: lesson.toLesson()).count, vocabs.count)
  }
  
  func test_getListOfVocab_vocabContentAreSame() {
    let (_, _, _, lesson, vocabs, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    let sampleVocabID = vocab.id
    
    makeFakeHistory(for: vocab,
                    historyRealmProvider: historyRealmProvider,
                    testTaken: testTaken,
                    correctAnswer: correctAnswer,
                    isLearned: true,
                    isMastered: false,
                    isSynced: true,
                    firstLearnDate: firstLearnDate,
                    lastTimeTest: lastTimeTest)
    
    let returnedVocabs = sut.getListOfVocabs(in: lesson.toLesson()).sorted { $0.id < $1.id }
    let originVocabs = vocabs.sorted { $0.id < $1.id }
    
    XCTAssertEqual(originVocabs.count, returnedVocabs.count)
    
    for i in 0..<originVocabs.count {
      if originVocabs[i].id != returnedVocabs[i].id ||
        originVocabs[i].word != returnedVocabs[i].word ||
        originVocabs[i].translations.count != returnedVocabs[i].translations.count {
        XCTFail()
      }
      
      for trans in originVocabs[i].translations {
        if returnedVocabs[i].translations[trans.getLanguageCodeAndTranslation().0] == nil {
          XCTFail()
        }
      }
      
      if returnedVocabs[i].id == sampleVocabID {
        let vocabPractice = returnedVocabs[i].practiceHistory
        if vocabPractice.numberOfCorrectAnswer != correctAnswer ||
          vocabPractice.numberOfTestTaken != testTaken ||
          vocabPractice.isLearned != true ||
          vocabPractice.isMastered != false ||
          vocabPractice.firstLearnDate != firstLearnDate ||
          vocabPractice.lastTimeTest != lastTimeTest {
          XCTFail()
        }
      }
    }
  }
  
  func test_getVocabByID_notExistedVocab_returnNil() {
    let (_, _, _, _, _, _) = makeSampleVocabsData(into: bundledRealmProvider)
    
    let vocab = sut.getVocab(by: 999)
    XCTAssertNil(vocab)
  }
  
  func test_getVocabByID_existedVocab_returnCorrectVocab() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    let v = sut.getVocab(by: UInt(vocab.id))
    XCTAssertNotNil(vocab)
    
    if vocab.id != v!.id ||
      vocab.word != v!.word ||
      vocab.translations.count != v!.translations.count {
      XCTFail()
    }
    
    for trans in vocab.translations {
      if v!.translations[trans.getLanguageCodeAndTranslation().0] == nil {
        XCTFail()
      }
    }
  }
  
  func test_markVocabAsMastered_returnVocabIsMastered() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    sut.markVocabAsMastered(vocab.toVocab())
    
    let v = sut.getVocab(by: UInt(vocab.id))
    
    XCTAssertNotNil(v)
    XCTAssertTrue(v!.practiceHistory.isMastered)
  }
  
  func test_markVocabAsMastered_setIsSyncedToFalse() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    makeFakeHistory(for: vocab, historyRealmProvider: historyRealmProvider, testTaken: testTaken, correctAnswer: correctAnswer, isLearned: true, isMastered: false, isSynced: true, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    
    sut.markVocabAsMastered(vocab.toVocab())
    
    let vocabHistory = historyRealmProvider.realm.object(ofType: RealmVocabPracticeHistory.self, forPrimaryKey: vocab.id)
    
    XCTAssertNotNil(vocabHistory)
    XCTAssertFalse(vocabHistory!.isSynced)
  }
  
  func test_markVocabAsMastered_newVocab_markVocabAsLearned() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    sut.markVocabAsMastered(vocab.toVocab())
    
    let v = sut.getVocab(by: UInt(vocab.id))
    
    XCTAssertNotNil(v)
    XCTAssertTrue(v!.practiceHistory.isLearned)
  }
  
  func test_recordVocabPracticed_notPracticeVocab_correctAnswer_correctAnswerIs1() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    sut.recordVocabPracticed(vocab: vocab.toVocab(), isCorrectAnswer: true)
    
    let v = sut.getVocab(by: UInt(vocab.id))
    
    XCTAssertNotNil(v)
    XCTAssertEqual(v!.practiceHistory.numberOfTestTaken, 1)
    XCTAssertEqual(v!.practiceHistory.numberOfCorrectAnswer, 1)
    XCTAssertEqual(v!.practiceHistory.numberOfWrongAnswer, 0)
    XCTAssertTrue(v!.practiceHistory.isLearned)
  }
  
  func test_recordVocabPracticed_notPracticeVocab_wrongAnswer_correctAnswerIs0() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    sut.recordVocabPracticed(vocab: vocab.toVocab(), isCorrectAnswer: false)
    
    let v = sut.getVocab(by: UInt(vocab.id))
    
    XCTAssertNotNil(v)
    XCTAssertEqual(v!.practiceHistory.numberOfTestTaken, 1)
    XCTAssertEqual(v!.practiceHistory.numberOfCorrectAnswer, 0)
    XCTAssertEqual(v!.practiceHistory.numberOfWrongAnswer, 1)
    XCTAssertTrue(v!.practiceHistory.isLearned)
  }
  
  func test_recordVocabPracticed_increaseCorrectAnswerBy1() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    makeFakeHistory(for: vocab, historyRealmProvider: historyRealmProvider, testTaken: testTaken, correctAnswer: correctAnswer, isLearned: false, isMastered: false, isSynced: true, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    
    sut.recordVocabPracticed(vocab: vocab.toVocab(), isCorrectAnswer: true)
    
    let v = sut.getVocab(by: UInt(vocab.id))
    
    XCTAssertNotNil(v)
    XCTAssertEqual(v!.practiceHistory.numberOfCorrectAnswer, UInt(correctAnswer + 1))
    XCTAssertTrue(v!.practiceHistory.isLearned)
  }
  
  func test_recordVocabPracticed_increaseWrongAnswerBy1() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    makeFakeHistory(for: vocab, historyRealmProvider: historyRealmProvider, testTaken: testTaken, correctAnswer: correctAnswer, isLearned: false, isMastered: false, isSynced: true, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    
    sut.recordVocabPracticed(vocab: vocab.toVocab(), isCorrectAnswer: false)
    
    let v = sut.getVocab(by: UInt(vocab.id))
    
    XCTAssertNotNil(v)
    XCTAssertEqual(v!.practiceHistory.numberOfWrongAnswer, UInt(testTaken - correctAnswer + 1))
    XCTAssertTrue(v!.practiceHistory.isLearned)
  }
  
  func test_recordVocabPractice_newVocab_markVocabAsLearned() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    sut.recordVocabPracticed(vocab: vocab.toVocab(), isCorrectAnswer: false)
    
    let v = sut.getVocab(by: UInt(vocab.id))
    
    XCTAssertNotNil(v)
    XCTAssertTrue(v!.practiceHistory.isLearned)
  }
  
  func test_recordVocabPractice_newVocab_updateFirstLearnDate() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    sut.recordVocabPracticed(vocab: vocab.toVocab(), isCorrectAnswer: false)
    
    let v = sut.getVocab(by: UInt(vocab.id))
    
    XCTAssertNotNil(v)
    XCTAssertNotNil(v!.practiceHistory.firstLearnDate)
  }
  
  func test_recordVocabPractice_newVocab_updateLastTimeTest() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    sut.recordVocabPracticed(vocab: vocab.toVocab(), isCorrectAnswer: false)
    
    let v = sut.getVocab(by: UInt(vocab.id))
    
    XCTAssertNotNil(v)
    XCTAssertNotNil(v!.practiceHistory.lastTimeTest)
  }
  
  func test_recordVocabPractice_oldVocab_notUpdateFirstLearnDate() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    makeFakeHistory(for: vocab, historyRealmProvider: historyRealmProvider, testTaken: testTaken, correctAnswer: correctAnswer, isLearned: false, isMastered: false, isSynced: true, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    
    sut.recordVocabPracticed(vocab: vocab.toVocab(), isCorrectAnswer: false)
    
    let v = sut.getVocab(by: UInt(vocab.id))
    
    XCTAssertNotNil(v)
    XCTAssertEqual(v!.practiceHistory.firstLearnDate!, firstLearnDate)
  }
  
  func test_recordVocabPractice_oldVocab_updateLastTimeTest() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    makeFakeHistory(for: vocab, historyRealmProvider: historyRealmProvider, testTaken: testTaken, correctAnswer: correctAnswer, isLearned: false, isMastered: false, isSynced: true, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    
    sut.recordVocabPracticed(vocab: vocab.toVocab(), isCorrectAnswer: false)
    
    let v = sut.getVocab(by: UInt(vocab.id))
    
    XCTAssertNotNil(v)
    XCTAssertGreaterThan(v!.practiceHistory.lastTimeTest!, lastTimeTest)
  }
  
  func test_recordVocabPracticed_UpdateLessonPracticeHistory() {
    let (_, _, _, lesson, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    makeFakeHistory(for: vocab, historyRealmProvider: historyRealmProvider, testTaken: testTaken, correctAnswer: correctAnswer, isLearned: false, isMastered: false, isSynced: true, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    
    sut.recordVocabPracticed(vocab: vocab.toVocab(), isCorrectAnswer: false)
    
    let lessonHistory = historyRealmProvider.realm.object(ofType: RealmLessonHistory.self, forPrimaryKey: lesson.id)
    
    XCTAssertNotNil(lessonHistory)
    XCTAssertGreaterThan(lessonHistory!.lastTimeLearned!, lastTimeTest)
  }
  
  func test_searchVocab_existedKeyword_returnVocab() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    makeFakeHistory(for: vocab, historyRealmProvider: historyRealmProvider, testTaken: testTaken, correctAnswer: correctAnswer, isLearned: false, isMastered: false, isSynced: true, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    
    let vocabs = sut.searchVocab(keyword: vocab.translations[0].translation)
    
    XCTAssertGreaterThanOrEqual(vocabs.count, 1)
  }
  
  func test_searchVocab_existedKeyword_lowercased_returnVocab() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    makeFakeHistory(for: vocab, historyRealmProvider: historyRealmProvider, testTaken: testTaken, correctAnswer: correctAnswer, isLearned: false, isMastered: false, isSynced: true, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    
    let vocabs = sut.searchVocab(keyword: vocab.translations[0].translation.lowercased())
    
    XCTAssertGreaterThanOrEqual(vocabs.count, 1)
  }
  
  func test_searchVocab_existedKeyword_uppercased_returnVocab() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    makeFakeHistory(for: vocab, historyRealmProvider: historyRealmProvider, testTaken: testTaken, correctAnswer: correctAnswer, isLearned: false, isMastered: false, isSynced: true, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    
    let vocabs = sut.searchVocab(keyword: vocab.translations[0].translation.uppercased())
    
    XCTAssertGreaterThanOrEqual(vocabs.count, 1)
  }
  
  func test_searchVocab_popularKeyword_returnMoreThan1Vocabs() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    makeFakeHistory(for: vocab, historyRealmProvider: historyRealmProvider, testTaken: testTaken, correctAnswer: correctAnswer, isLearned: false, isMastered: false, isSynced: true, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    
    let vocabs = sut.searchVocab(keyword: "n")
    
    XCTAssertGreaterThan(vocabs.count, 1)
  }
  
  func test_syncLessonProficiency_notExisted_SyncedWithNewData() {
    let (_, _, _, lesson, _, _) = makeSampleVocabsData(into: bundledRealmProvider)
    
    let lastTimeSynced = (Date() - 1.days - 1.hours).timeIntervalSince1970
    let proficiency = 80
    sut.syncLessonProficiency(lessonID: UInt(lesson.id), proficiency: UInt8(proficiency), lastTimeSynced: lastTimeSynced)
    
    let historyRealm = historyRealmProvider.realm
    let lessonHistory = historyRealm.object(ofType: RealmLessonHistory.self,
                                            forPrimaryKey: lesson.id)
    
    XCTAssertNotNil(lessonHistory)
    XCTAssertFalse(lessonHistory!.isSynced)
    XCTAssertEqual(lessonHistory!.lastTimeSynced.value, lastTimeSynced)
    XCTAssertEqual(lessonHistory!.proficiency, proficiency)
  }
  
  func test_syncLessonProficiency_localLastTimeSyncedLargeThanServerData_KeepLocalData() {
    let (_, _, _, lesson, _, _) = makeSampleVocabsData(into: bundledRealmProvider)
    
    let localLastTimeSynced = (Date() - 1.days).timeIntervalSince1970
    let localProficiency = 90
    
    makeFakeHistory(for: lesson, historyRealmProvider: historyRealmProvider, lastTimeSynced: localLastTimeSynced, proficiency: localProficiency)
    
    let lastTimeSynced = (Date() - 1.days - 1.hours).timeIntervalSince1970
    let proficiency = 80
    sut.syncLessonProficiency(lessonID: UInt(lesson.id), proficiency: UInt8(proficiency), lastTimeSynced: lastTimeSynced)
    
    let historyRealm = historyRealmProvider.realm
    let lessonHistory = historyRealm.object(ofType: RealmLessonHistory.self,
                                            forPrimaryKey: lesson.id)
    
    XCTAssertNotNil(lessonHistory)
    XCTAssertTrue(lessonHistory!.isSynced)
    XCTAssertEqual(lessonHistory!.lastTimeSynced.value, localLastTimeSynced)
    XCTAssertEqual(lessonHistory!.proficiency, localProficiency)
  }
  
  func test_syncLessonProficiency_localLastTimeSyncedSmallerThanServerData_SyncServerData() {
    let (_, _, _, lesson, _, _) = makeSampleVocabsData(into: bundledRealmProvider)
    
    let localLastTimeSynced = (Date() - 1.days).timeIntervalSince1970
    let localProficiency = 90
    
    makeFakeHistory(for: lesson, historyRealmProvider: historyRealmProvider, lastTimeSynced: localLastTimeSynced, proficiency: localProficiency)
    
    let lastTimeSynced = (Date() - 1.hours).timeIntervalSince1970
    let proficiency = 80
    sut.syncLessonProficiency(lessonID: UInt(lesson.id), proficiency: UInt8(proficiency), lastTimeSynced: lastTimeSynced)
    
    let historyRealm = historyRealmProvider.realm
    let lessonHistory = historyRealm.object(ofType: RealmLessonHistory.self,
                                            forPrimaryKey: lesson.id)
    
    XCTAssertNotNil(lessonHistory)
    XCTAssertFalse(lessonHistory!.isSynced)
    XCTAssertEqual(lessonHistory!.lastTimeSynced.value, lastTimeSynced)
    XCTAssertEqual(lessonHistory!.proficiency, proficiency)
  }
  
  func test_syncVocabPracticeHistory_ServerTestTakenGreaterThanLocalTestTaken_SyncServerData() {
    let (_, _, _, _, _, vocab) = makeSampleVocabsData(into: bundledRealmProvider)
    
    let serverTestTaken = testTaken + 2
    let serverCorrectAnswer = correctAnswer + 1
    
    makeFakeHistory(for: vocab, historyRealmProvider: historyRealmProvider, testTaken: testTaken, correctAnswer: correctAnswer, isLearned: false, isMastered: false, isSynced: true, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    
    sut.syncPracticeHistory(vocabID: UInt(vocab.id),
                            isMastered: false,
                            testTaken: serverTestTaken,
                            correctAnswer: serverCorrectAnswer,
                            firstLearnDate: firstLearnDate,
                            lastTimeTest: lastTimeTest)
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
  
  private func makeSampleVocabsData(into realmProvider: RealmProvider) -> ([RealmBook], RealmBook, [RealmLesson], RealmLesson, [RealmVocab], RealmVocab) {
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
    
    let vocabs = [vocab1, vocab2, vocab3, vocab4, vocab5, vocab6, vocab7, vocab8, vocab9, vocab10, vocab11]
    
    let lesson1 = RealmLesson(id: 1, name: "제1과 1", index: 1, translations: lesson1Trans, readingParts: [readingPart], vocabs: vocabs)
    let lesson2 = RealmLesson(id: 2, name: "제1과 2", index: 2, translations: lesson2Trans, readingParts: [], vocabs: [])
    let lesson3 = RealmLesson(id: 3, name: "제1과 3", index: 3, translations: lesson3Trans, readingParts: [], vocabs: [])
    let lesson4 = RealmLesson(id: 4, name: "제1과 4", index: 4, translations: lesson4Trans, readingParts: [], vocabs: [])
    let lesson5 = RealmLesson(id: 5, name: "제1과 5", index: 5, translations: lesson5Trans, readingParts: [], vocabs: [])
    
    let lessons = [lesson1, lesson2, lesson3, lesson4, lesson5]
    
    let book1 = RealmBook(id: 1, name: "한국어와 한국문화\n 기조", thumbName: nil, lessons: lessons)
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
    
    let books = [book1, book2, book3, book4, book5, book6, book7]
    
    return (books, book1, lessons, lesson1, vocabs, vocab1)
  }
  
  private func makeFakeHistory(for lesson: RealmLesson,
                               historyRealmProvider: RealmProvider,
                               lastTimeSynced: Double,
                               proficiency: Int) {
    let realm = historyRealmProvider.realm
    
    if let history = realm.object(ofType: RealmLessonHistory.self, forPrimaryKey: lesson.id) {
      try! realm.write {
        history.lastTimeSynced.value = lastTimeSynced
      }
    }
    else {
      let history = RealmLessonHistory(lessonID: lesson.id, isSynced: true, lastTimeSynced: lastTimeSynced, proficiency: proficiency, lastTimeLearned: nil)
      try! realm.write {
        realm.add(history)
      }
    }
  }
  
  private func makeFakeHistory(for vocab: RealmVocab,
                               historyRealmProvider: RealmProvider,
                               testTaken: Int,
                               correctAnswer: Int,
                               isLearned: Bool,
                               isMastered: Bool,
                               isSynced: Bool,
                               firstLearnDate: Date?,
                               lastTimeTest: Date?) {
    let realm = historyRealmProvider.realm
    
    if let history = realm.object(ofType: RealmVocabPracticeHistory.self, forPrimaryKey: vocab.id) {
      try! realm.write {
        history.testTaken = testTaken
        history.correctAnswer = correctAnswer
        history.wrongAnswer = testTaken - correctAnswer
        history.isLearned = isLearned
        history.isMastered = isMastered
        history.isSynced = isSynced
        history.firstLearnDate = firstLearnDate
        history.lastTimeTest = lastTimeTest
      }
    }
    else {
      let history = RealmVocabPracticeHistory(vocabID: vocab.id,
                                              testTaken: testTaken,
                                              correctAnswer: correctAnswer,
                                              wrongAnswer: testTaken - correctAnswer,
                                              isLearned: isLearned,
                                              isMastered: isMastered,
                                              firstLearnDate: firstLearnDate,
                                              lastTimeTest: lastTimeTest)
      history.isSynced = isSynced
      try! realm.write {
        realm.add(history)
      }
    }
  }
}
