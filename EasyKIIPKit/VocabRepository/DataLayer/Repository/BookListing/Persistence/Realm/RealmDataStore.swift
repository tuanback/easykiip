//
//  RealmDataStore.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/09.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
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
    let realm = bundledRealmProvider.realm
    guard let book = realm.object(ofType: RealmBook.self, forPrimaryKey: book.id) else {
      return []
    }
    let lessons: [Lesson] = book.lessons.map({ $0.toLesson() })
    return lessons
  }
  
  func getListOfVocabs(in lesson: Lesson) -> [Vocab] {
    let realm = bundledRealmProvider.realm
    let historyRealm = historyRealmProvider.realm
    
    guard let lesson = realm.object(ofType: RealmLesson.self, forPrimaryKey: lesson.id) else {
      return []
    }
    
    let vocabs: [Vocab] = lesson.vocabs.map { (realmVocab) -> Vocab in
      let vocabHistory = historyRealm.object(ofType: RealmVocabPracticeHistory.self, forPrimaryKey: realmVocab.id)
      return getVocab(from: realmVocab, vocabHistory: vocabHistory)
    }
    return vocabs
  }
  
  func markVocabAsMastered(_ vocab: Vocab) {
    let time = Date()
    
    let historyRealm = historyRealmProvider.realm
    // Check if history is existed => Update else create
    if let history = historyRealm.object(ofType: RealmVocabPracticeHistory.self,
                                         forPrimaryKey: vocab.id) {
      try! historyRealm.write {
        history.isMastered = true
        history.isLearned = true
        history.isSynced = false
      }
    }
    else {
      let vocabHis = vocab.practiceHistory
      let history = RealmVocabPracticeHistory(vocabID: Int(vocab.id),
                                              testTaken: Int(vocabHis.numberOfTestTaken),
                                              correctAnswer: Int(vocabHis.numberOfCorrectAnswer),
                                              wrongAnswer: Int(vocabHis.numberOfWrongAnswer),
                                              isLearned: true,
                                              isMastered: true,
                                              firstLearnDate: vocabHis.firstLearnDate,
                                              lastTimeTest: vocabHis.lastTimeTest)
      
      history.isSynced = false
      
      if let lessonHisory = getRealmLessonHistory(of: vocab) {
        try! historyRealm.write {
          lessonHisory.vocabsHistory.append(history)
        }
      }
      else if let lesson = getRealmLesson(of: vocab) {
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
    
    updateLessonLastLearnDate(vocab: vocab, date: time)
  }
  
  func recordVocabPracticed(vocab: Vocab, isCorrectAnswer: Bool) {
    let time = Date()
    
    let historyRealm = historyRealmProvider.realm
    // Check if history is existed => Update else create
    if let history = historyRealm.object(ofType: RealmVocabPracticeHistory.self,
                                         forPrimaryKey: vocab.id) {
      try! historyRealm.write {
        history.testTaken += 1
        if isCorrectAnswer {
          history.correctAnswer += 1
        }
        history.isLearned = true
        history.isMastered = vocab.practiceHistory.isMastered
        
        if history.firstLearnDate == nil {
          history.firstLearnDate = time
        }
        history.lastTimeTest = time
      }
    }
    else {
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
      
      if let lessonHisory = getRealmLessonHistory(of: vocab) {
        try! historyRealm.write {
          lessonHisory.vocabsHistory.append(history)
        }
      }
      else if let lesson = getRealmLesson(of: vocab) {
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
    
    updateLessonLastLearnDate(vocab: vocab, date: time)
  }
  
  private func getRealmLesson(of vocab: Vocab) -> RealmLesson? {
    let bundledRealm = bundledRealmProvider.realm
    let realmLesson = bundledRealm.objects(RealmLesson.self).first { (lesson) -> Bool in
      if let _ = lesson.vocabs.first(where: { $0.id == vocab.id }) {
        return true
      }
      return false
    }
    return realmLesson
  }
  
  private func getRealmLessonHistory(of vocab: Vocab) -> RealmLessonHistory? {
    let historyRealm = historyRealmProvider.realm
    let realmLessonHistory = historyRealm.objects(RealmLessonHistory.self).first { (lesson) -> Bool in
      if let _ = lesson.vocabsHistory.first(where: { $0.vocabID == vocab.id }) {
        return true
      }
      return false
    }
    return realmLessonHistory
  }
  
  private func updateLessonLastLearnDate(vocab: Vocab, date: Date) {
    guard let realmLesson = getRealmLesson(of: vocab) else { return }
    let lessonID = realmLesson.id
    
    let historyRealm = historyRealmProvider.realm
    
    if let lessonHistory = getRealmLessonHistory(of: vocab) {
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
      }
    }
  }
  
  func getVocab(by id: UInt) -> Vocab? {
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
  
  func searchVocab(keyword: String) -> [Vocab] {
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
  
  func syncLessonProficiency(lessonID: UInt, proficiency: UInt8, lastTimeSynced: Double) {
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
  
  func syncPracticeHistory(vocabID: Int, isMastered: Bool, testTaken: Int, correctAnswer: Int, firstLearnDate: Date, lastTimeTest: Date) {
    // TODO: need to add test here
    
  }
  
  // Helpers
  private func getVocab(from realmVocab: RealmVocab, vocabHistory: RealmVocabPracticeHistory?) -> Vocab {
    
    let vocab = realmVocab.toVocab()
    
    if let history = vocabHistory {
      vocab.setTestTakenData(isMastered: history.isMastered,
                             numberOfTestTaken: UInt(history.testTaken),
                             numberOfCorrectAnswer: UInt(history.correctAnswer),
                             firstLearnDate: history.firstLearnDate,
                             lastTimeTest: history.lastTimeTest)
    }
    return vocab
  }
}
