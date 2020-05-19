//
//  RealmDataStore.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/09.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RealmSwift

public struct RealmProvider {
  
  let configuration: Realm.Configuration
  
  init(config: Realm.Configuration) {
    self.configuration = config
  }
  
  var realm: Realm {
    return try! Realm(configuration: configuration)
  }
  
  public static var bundled: RealmProvider = {
    return RealmProvider(config: bundledConfig)
  }()
  
  // MARK: - Bundled sets
  private static let bundledConfig = Realm.Configuration(
    fileURL: try! Path.inBundle(bundle: Bundle(identifier: "com.tuando.EasyKIIPKit")!, fileName: "vocabBundled.realm"),
    readOnly: true)
  
  public static var history: RealmProvider {
    return RealmProvider(config: historyConfig)
  }
  
  private static let historyConfig = Realm.Configuration(
    fileURL: try! Path.inDocuments("practiceHistory.realm")
  )
}

public class RealmDataStore: VocabDataStore {
  
  private let bundledRealmProvider: RealmProvider
  private let historyRealmProvider: RealmProvider
  
  public convenience init() {
    self.init(bundled: RealmProvider.bundled, history: RealmProvider.history)
  }
  
  init(bundled: RealmProvider = RealmProvider.bundled, history: RealmProvider = RealmProvider.history) {
    self.bundledRealmProvider = bundled
    self.historyRealmProvider = history
  }
  
  public func getListOfBook() -> [Book] {
    let realm = bundledRealmProvider.realm
    let realmBooks = realm.objects(RealmBook.self)
    return realmBooks.map { $0.toBook() }
  }
  
  public func getListOfLesson(inBook id: Int) -> [Lesson] {
    let realm = bundledRealmProvider.realm
    let historyRealm = historyRealmProvider.realm
    guard let book = realm.object(ofType: RealmBook.self, forPrimaryKey: id) else {
      return []
    }
    let lessons: [Lesson] = book.lessons.map { (realmLesson) -> Lesson in
      let lessonHistory = historyRealm.object(ofType: RealmLessonHistory.self, forPrimaryKey: realmLesson.id)
      return getLesson(from: realmLesson, lessonHistory: lessonHistory)
    }
    return lessons
  }
  
  public func getListOfVocabs(inLesson id: Int) -> [Vocab] {
    let realm = bundledRealmProvider.realm
    let historyRealm = historyRealmProvider.realm
    
    guard let lesson = realm.object(ofType: RealmLesson.self, forPrimaryKey: id) else {
      return []
    }
    
    let vocabs: [Vocab] = lesson.vocabs.map { (realmVocab) -> Vocab in
      let vocabHistory = historyRealm.object(ofType: RealmVocabPracticeHistory.self, forPrimaryKey: realmVocab.id)
      return getVocab(from: realmVocab, vocabHistory: vocabHistory)
    }
    return vocabs
  }
  
  public func markVocabAsMastered(vocabID id: Int) {
    let time = Date()
    
    let historyRealm = historyRealmProvider.realm
    // Check if history is existed => Update else create
    if let history = historyRealm.object(ofType: RealmVocabPracticeHistory.self,
                                         forPrimaryKey: id) {
      try! historyRealm.write {
        history.isMastered = true
        history.isLearned = true
        history.isSynced = false
      }
    }
    else {
      guard let vocab = getVocab(by: id) else { return }
      let vocabHis = vocab.practiceHistory
      let history = RealmVocabPracticeHistory(vocabID: Int(id),
                                              testTaken: Int(vocabHis.numberOfTestTaken),
                                              correctAnswer: Int(vocabHis.numberOfCorrectAnswer),
                                              wrongAnswer: Int(vocabHis.numberOfWrongAnswer),
                                              isLearned: true,
                                              isMastered: true,
                                              firstLearnDate: vocabHis.firstLearnDate,
                                              lastTimeTest: vocabHis.lastTimeTest)
      
      history.isSynced = false
      
      if let lessonHisory = getRealmLessonHistoryContains(vocabID: id) {
        try! historyRealm.write {
          lessonHisory.vocabsHistory.append(history)
        }
      }
      else if let lesson = getRealmLesson(of: vocab.id) {
        let lessonHistory = RealmLessonHistory(lessonID: lesson.index,
                                               isSynced: false,
                                               lastTimeSynced: nil,
                                               proficiency: 0,
                                               lastTimeLearned: time)
        lessonHistory.vocabsHistory.append(history)
        try! historyRealm.write {
          historyRealm.add(lessonHistory)
        }
      }
    }
    
    updateLessonLastLearnDate(vocabID: id, date: time)
  }
  
  public func recordVocabPracticed(vocabID: Int, isCorrectAnswer: Bool) {
    let time = Date()
    
    let historyRealm = historyRealmProvider.realm
    // Check if history is existed => Update else create
    if let history = historyRealm.object(ofType: RealmVocabPracticeHistory.self,
                                         forPrimaryKey:vocabID) {
      let vocab = getVocab(by: vocabID)
      
      try! historyRealm.write {
        history.testTaken += 1
        if isCorrectAnswer {
          history.correctAnswer += 1
        }
        history.isLearned = true
        history.isMastered = vocab?.practiceHistory.isMastered ?? false
        
        if history.firstLearnDate == nil {
          history.firstLearnDate = time
        }
        history.lastTimeTest = time
      }
    }
    else {
      guard let vocab = getVocab(by: vocabID) else { return }
      let correctAnswer = isCorrectAnswer ? 1 : 0
      let wrongAnswer = isCorrectAnswer ? 0 : 1
      let history = RealmVocabPracticeHistory(vocabID: Int(vocab.id),
                                              testTaken: 1,
                                              correctAnswer: correctAnswer,
                                              wrongAnswer: wrongAnswer,
                                              isLearned: true,
                                              isMastered: false,
                                              firstLearnDate: time,
                                              lastTimeTest: time)
      history.isSynced = false
      
      if let lessonHisory = getRealmLessonHistoryContains(vocabID: vocab.id) {
        try! historyRealm.write {
          lessonHisory.vocabsHistory.append(history)
        }
      }
      else if let lesson = getRealmLesson(of: vocab.id) {
        let lessonHistory = RealmLessonHistory(lessonID: lesson.index,
                                               isSynced: false,
                                               lastTimeSynced: nil,
                                               proficiency: 0, lastTimeLearned: time)
        lessonHistory.vocabsHistory.append(history)
        try! historyRealm.write {
          historyRealm.add(lessonHistory)
        }
      }
    }
    
    updateLessonLastLearnDate(vocabID: vocabID, date: time)
  }
  
  private func getRealmLesson(of vocabID: Int) -> RealmLesson? {
    let bundledRealm = bundledRealmProvider.realm
    let realmLesson = bundledRealm.objects(RealmLesson.self).first { (lesson) -> Bool in
      if let _ = lesson.vocabs.first(where: { $0.id == vocabID }) {
        return true
      }
      return false
    }
    return realmLesson
  }
  
  private func getRealmLessonHistoryContains(vocabID: Int) -> RealmLessonHistory? {
    let bundleRealm = bundledRealmProvider.realm
    let historyRealm = historyRealmProvider.realm
    
    let realmLesson = bundleRealm.objects(RealmLesson.self).first {
      (lesson) -> Bool in
      if let _ = lesson.vocabs.first(where: { $0.id == vocabID }) {
        return true
      }
      return false
    }
    
    guard let lessonID = realmLesson?.id else {
      return nil
    }
    
    let realmLessonHistory = historyRealm.object(ofType: RealmLessonHistory.self, forPrimaryKey: lessonID)
    return realmLessonHistory
  }
  
  private func updateLessonLastLearnDate(vocabID: Int, date: Date) {
    guard let realmLesson = getRealmLesson(of: vocabID) else { return }
    let lessonID = realmLesson.id
    
    let historyRealm = historyRealmProvider.realm
    
    if let lessonHistory = getRealmLessonHistoryContains(vocabID: vocabID) {
      try! historyRealm.write {
        lessonHistory.lastTimeLearned = date
        lessonHistory.isSynced = false
        lessonHistory.proficiency = Int(lessonHistory.calculateProficiency())
      }
    }
    else {
      let lessonHistory = RealmLessonHistory(lessonID: lessonID,
                                             isSynced: false,
                                             lastTimeSynced: nil,
                                             proficiency: 0, lastTimeLearned: date)
      
      try! historyRealm.write {
        historyRealm.add(lessonHistory)
        lessonHistory.proficiency = Int(lessonHistory.calculateProficiency())
      }
    }
  }
  
  public func getLesson(by id: Int) -> Lesson? {
    let bundledRealm = bundledRealmProvider.realm
    let historyRealm = historyRealmProvider.realm
    guard let realmLesson = bundledRealm.object(ofType: RealmLesson.self, forPrimaryKey: id)
      else {
        return nil
    }
    
    let realmHistory = historyRealm.object(ofType: RealmLessonHistory.self, forPrimaryKey: id)
    
    let lesson = getLesson(from: realmLesson, lessonHistory: realmHistory)
    
    return lesson
  }
  
  public func getVocab(by id: Int) -> Vocab? {
    let bundledRealm = bundledRealmProvider.realm
    let historyRealm = historyRealmProvider.realm
    guard let realmVocab = bundledRealm.object(ofType: RealmVocab.self, forPrimaryKey: id)
      else {
        return nil
    }
    
    let realmHistory = historyRealm.object(ofType: RealmVocabPracticeHistory.self, forPrimaryKey: id)
    
    let vocab = getVocab(from: realmVocab, vocabHistory: realmHistory)
    
    return vocab
  }
  
  public func getNotSyncedVocabsInLesson(lessonID: Int) -> [Vocab] {
    
    let bundledRealm = bundledRealmProvider.realm
    let historyRealm = historyRealmProvider.realm
    
    guard let realmLesson = historyRealm.object(ofType: RealmLessonHistory.self, forPrimaryKey: lessonID) else {
      return []
    }
    
    let notSyncedVocabs: [RealmVocabPracticeHistory] = realmLesson.vocabsHistory.filter {
      !$0.isSynced
    }
    
    let vocabs: [Vocab] = notSyncedVocabs.compactMap { (realmVocabHistory) -> Vocab? in
      
      if let realmVocab = bundledRealm.object(ofType: RealmVocab.self, forPrimaryKey: realmVocabHistory.vocabID) {
        return getVocab(from: realmVocab, vocabHistory: realmVocabHistory)
      }
      
      return nil
    }
    
    return vocabs
  }
  
  public func searchVocab(keyword: String) -> [Vocab] {
    let bundledRealm = bundledRealmProvider.realm
    let historyRealm = historyRealmProvider.realm
    
    let realmVocabs = bundledRealm.objects(RealmVocab.self).filter { (vocab) in
      for translation in vocab.translations {
        if translation.translation.lowercased().contains(keyword.lowercased()) {
          return true
        }
      }
      return false
    }
    
    let vocabs: [Vocab] = realmVocabs.map { (realmVocab) -> Vocab in
      let vocabHistory = historyRealm.object(ofType: RealmVocabPracticeHistory.self, forPrimaryKey: realmVocab.id)
      return getVocab(from: realmVocab, vocabHistory: vocabHistory)
    }
   
    return vocabs
  }
  
  public func syncLessonProficiency(lessonID: Int, proficiency: UInt8, lastTimeSynced: Double) {
    let historyRealm = historyRealmProvider.realm
    
    //Lesson history is existed and synced
    if let lessonHistory = historyRealm.object(ofType: RealmLessonHistory.self, forPrimaryKey: lessonID),
      let historyLastTimeSynced = lessonHistory.lastTimeSynced.value {
      
      // If local last time synced > server last time synced => No need to update other fields
      if historyLastTimeSynced >= lastTimeSynced {
        try! historyRealm.write {
          lessonHistory.isSynced = true
        }
        return
      }
      
      // Otherwise update local history with the data from server
      try! historyRealm.write {
        lessonHistory.isSynced = false
        lessonHistory.proficiency = Int(proficiency)
        lessonHistory.lastTimeSynced.value = lastTimeSynced
      }
      
      return
    }
    
    // Lesson history is not existed or never synced, need to sync the vocab also
    let lessonHistory = RealmLessonHistory(lessonID: Int(lessonID),
                                           isSynced: false,
                                           lastTimeSynced: lastTimeSynced,
                                           proficiency: Int(proficiency),
                                           lastTimeLearned: nil)
    try! historyRealm.write {
      historyRealm.add(lessonHistory)
    }
  }
  
  public func isLessonSynced(_ lessonID: Int) -> Bool {
    let historyRealm = historyRealmProvider.realm
    
    if let lessonHistory = historyRealm.object(ofType: RealmLessonHistory.self, forPrimaryKey: lessonID) {
      return lessonHistory.isSynced
    }
    
    return false
  }
  
  public func syncPracticeHistory(vocabID: Int, isMastered: Bool, testTaken: Int, correctAnswer: Int, firstLearnDate: Date?, lastTimeTest: Date?) {
    
    let time = Date()
    
    let historyRealm = historyRealmProvider.realm
    // Check if history is existed => Update else create
    if let history = historyRealm.object(ofType: RealmVocabPracticeHistory.self,
                                         forPrimaryKey: vocabID) {
      
      try! historyRealm.write {
        history.isMastered = (isMastered || history.isMastered)
        history.isLearned = ((testTaken > 0) || history.isLearned)
        
        if history.testTaken < testTaken {
          history.testTaken = testTaken
          history.correctAnswer = correctAnswer
          history.firstLearnDate = firstLearnDate
          history.lastTimeTest = lastTimeTest
          history.isSynced = true
        }
      }
      
      return
    }
    
    // History is not existed locally, create history
    let history = RealmVocabPracticeHistory(vocabID: vocabID,
                                            testTaken: testTaken,
                                            correctAnswer: correctAnswer,
                                            wrongAnswer: testTaken - correctAnswer,
                                            isLearned: testTaken > 0,
                                            isMastered: isMastered,
                                            firstLearnDate: firstLearnDate,
                                            lastTimeTest: lastTimeTest)
    
    history.isSynced = true
    
    if let lessonHisory = getRealmLessonHistoryContains(vocabID:  vocabID) {
      try! historyRealm.write {
        lessonHisory.vocabsHistory.append(history)
      }
    }
    else if let lesson = getRealmLesson(of: vocabID) {
      let lessonHistory = RealmLessonHistory(lessonID: lesson.index,
                                             isSynced: false,
                                             lastTimeSynced: nil,
                                             proficiency: 0,
                                             lastTimeLearned: time)
      lessonHistory.vocabsHistory.append(history)
      try! historyRealm.write {
        historyRealm.add(lessonHistory)
      }
    }
    
  }
  
  public func setLessonSynced(lessonID: Int, lastTimeSynced: Double) {
    let historyRealm = historyRealmProvider.realm
    
    guard let realmLessonHistory = historyRealm.object(ofType: RealmLessonHistory.self, forPrimaryKey: lessonID) else {
      return
    }
    
    try! historyRealm.write {
      realmLessonHistory.isSynced = true
      realmLessonHistory.lastTimeSynced.value = lastTimeSynced
    }
    
  }
  
  // Helpers
  private func getLesson(from realmLesson: RealmLesson, lessonHistory: RealmLessonHistory?) -> Lesson {
    
    let lesson = realmLesson.toLesson()
    
    if let history = lessonHistory {
      lesson.setProficiency(UInt8(history.proficiency))
      lesson.setLastTimeLearned(history.lastTimeLearned)
    }
    return lesson
  }
  
  private func getVocab(from realmVocab: RealmVocab, vocabHistory: RealmVocabPracticeHistory?) -> Vocab {
    
    let vocab = realmVocab.toVocab()
    
    if let history = vocabHistory {
      vocab.setTestTakenData(isMastered: history.isMastered,
                             numberOfTestTaken: history.testTaken,
                             numberOfCorrectAnswer: history.correctAnswer,
                             firstLearnDate: history.firstLearnDate,
                             lastTimeTest: history.lastTimeTest)
    }
    return vocab
  }
}
