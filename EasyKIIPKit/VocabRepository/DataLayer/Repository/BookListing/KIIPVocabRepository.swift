//
//  KIIPVocabRepository.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftDate
import UserSession

public class KIIPVocabRepository: VocabRepository {
  
  private var userSession: UserSession
  private let remoteAPI: VocabRemoteAPI
  private let dataStore: VocabDataStore
  
  private var userID: String {
    return userSession.profile.id
  }
  
  public init(userSession: UserSession, remoteAPI: VocabRemoteAPI, dataStore: VocabDataStore) {
    self.userSession = userSession
    self.remoteAPI = remoteAPI
    self.dataStore = dataStore
  }
  
  public func getListOfBook() -> [Book] {
    dataStore.getListOfBook()
  }
  
  public func getListOfLesson(in book: Book) -> Observable<[Lesson]> {
    // Need to queries from auth remote then merge together
    let observable = BehaviorSubject<[Lesson]>(value: [])
    let dataStoreLessons = dataStore.getListOfLesson(in: book)
    
    remoteAPI.loadLessonData(userID: userID, bookID: book.id) { [weak self] (lessons) in
      guard let strongSelf = self else { return }
      // Algorithm to merge history from Back end with local datastore
      guard lessons.count > 0 else {
        observable.onNext(dataStoreLessons)
        return
      }
      
      for lesson in lessons {
        self?.dataStore.syncLessonProficiency(lessonID: lesson.id,
                                              proficiency: lesson.proficiency,
                                              lastTimeSynced: lesson.lastTimeSynced)
      }
      
      let syncedLessons = strongSelf.dataStore.getListOfLesson(in: book)
      observable.onNext(syncedLessons)
    }
    
    return observable
  }
  
  public func getListOfVocabs(in book: Book, lesson: Lesson) -> Observable<[Vocab]> {
    // Need to queries from auth remote then merge together
    let observable = PublishSubject<[Vocab]>()
    let dataStoreVocabs = dataStore.getListOfVocabs(in: lesson)
    
    if !dataStore.isLessonSynced(lesson.id) {
      remoteAPI.loadVocabData(userID: userID,
                              bookID: book.id,
                              lessonID: lesson.id) { [weak self] (vocabs) in
        guard let strongSelf = self else { return }
        // Algorithm to merge history from Back end with local datastore
        guard vocabs.count > 0 else {
          observable.onNext(dataStoreVocabs)
          return
        }
        
        for vocab in vocabs {
          var firstTimeLearned: Date?
          var lastTimeTest: Date?
          
          if let ftl = vocab.firstTimeLearned {
            firstTimeLearned = Date(timeIntervalSince1970: ftl)
          }
          if let ltt = vocab.lastTimeLearned {
            lastTimeTest = Date(timeIntervalSince1970: ltt)
          }
          
          self?.dataStore.syncPracticeHistory(
            vocabID: vocab.id,
            isMastered: vocab.isMastered,
            testTaken: vocab.testTaken,
            correctAnswer: vocab.correctAnswer,
            firstLearnDate: firstTimeLearned,
            lastTimeTest: lastTimeTest)
        }
        
        let syncedVocabs = strongSelf.dataStore.getListOfVocabs(in: lesson)
        observable.onNext(syncedVocabs)
      }
      
      return observable
    }
    
    return Observable<[Vocab]>.create { (observer) -> Disposable in
      let syncedVocabs = self.dataStore.getListOfVocabs(in: lesson)
      observer.onNext(syncedVocabs)
      return Disposables.create()
    }
  }
  
  public func markVocabAsMastered(_ vocab: Vocab) {
    dataStore.markVocabAsMastered(vocab)
  }
  
  public func recordVocabPracticed(vocab: Vocab, isCorrectAnswer: Bool) {
    dataStore.recordVocabPracticed(vocab: vocab, isCorrectAnswer: isCorrectAnswer)
  }
  
  public func searchVocab(keyword: String) -> [Vocab] {
    return dataStore.searchVocab(keyword: keyword)
  }
  
  public func getListOfLowProficiencyVocab(in book: Book, upto numberOfVocabs: Int) -> [Vocab] {
    var vocabs = dataStore.getListOfLesson(in: book)
      .flatMap { dataStore.getListOfVocabs(in: $0) }
    vocabs = vocabs.filter { $0.practiceHistory.isLearned }
    vocabs.sort { $0.proficiency < $1.proficiency }
    let numberOfElement = min(numberOfVocabs, vocabs.count)
    return Array(vocabs.prefix(upTo: numberOfElement))
  }
  
  public func getListOfLowProficiencyVocab(in lession: Lesson, upto numberOfVocabs: Int) -> [Vocab] {
    var vocabs = dataStore.getListOfVocabs(in: lession)
    vocabs = vocabs.filter { $0.practiceHistory.isLearned }
    vocabs.sort { $0.proficiency < $1.proficiency }
    let numberOfElement = min(numberOfVocabs, vocabs.count)
    return Array(vocabs.prefix(upTo: numberOfElement))
  }
  
  public func getNeedReviewVocabs(upto numberOfVocabs: Int) -> [Vocab] {
    let vocabs = getListOfBook()
      .flatMap { dataStore.getListOfLesson(in: $0)
        .flatMap { dataStore.getListOfVocabs(in: $0) }}
    return getNeedReviewVocabs(from: vocabs, upto: numberOfVocabs)
  }
  
  public func getNeedReviewVocabs(in book: Book, upto numberOfVocabs: Int) -> [Vocab] {
    let vocabs = dataStore.getListOfLesson(in: book)
      .flatMap { dataStore.getListOfVocabs(in: $0) }
    return getNeedReviewVocabs(from: vocabs, upto: numberOfVocabs)
  }
  
  private func getNeedReviewVocabs(from vocabs: [Vocab], upto numberOfVocabs: Int) -> [Vocab] {
    var result = vocabs.filter { vocab in
      guard vocab.practiceHistory.isLearned,
        let firstDate = vocab.practiceHistory.firstLearnDate,
        let lastDate = vocab.practiceHistory.lastTimeTest else {
          return false
      }
      
      // What should be algorithm here
      // If the vocab is learned yesterday but not practice today => Return true
      // Ask for review after 1 day
      if let deltaDayCompareToLastDay = (lastDate - firstDate).in(.day),
        deltaDayCompareToLastDay < 1,
        let deltaDayCompareToToday = (Date() - lastDate).in(.day),
        deltaDayCompareToToday >= 1 {
        return true
      }
      
      // Ask for review after 7 days, if the proficiency is lower than expected
      if let deltaDayCompareToToday = (Date() - firstDate).in(.day),
        deltaDayCompareToToday >= 7 {
        if vocab.proficiency <= 50 {
          return true
        }
      }
      
      // Ask for review after 1 month
      if let deltaDayCompareToToday = (Date() - firstDate).in(.day),
        deltaDayCompareToToday >= 30  {
        if vocab.proficiency <= 25 {
          return true
        }
      }
      return false
    }
    
    // Sort to get top N to review
    result.sort { $0.proficiency < $1.proficiency }
    let numberOfElement = min(numberOfVocabs, result.count)
    return Array(result.prefix(upTo: numberOfElement))
  }
  
  public func saveLessonPracticeHistory(in bookID: Int, lessonID: Int) {
    guard let updatedLesson = dataStore.getLesson(by: lessonID) else {
      return
    }
    
    let vocabs = dataStore.getNotSyncedVocabsInLesson(lessonID: lessonID)
    
    guard vocabs.count > 0 else {
      return
    }
    
    let lastTimeSynced = Date().timeIntervalSince1970
    let proficiency = updatedLesson.proficiency
    let firebaseLesson = FirebaseLesson(id: lessonID,
                                        proficiency: proficiency,
                                        lastTimeSynced: lastTimeSynced)
    
    dataStore.setLessonSynced(lessonID: lessonID, lastTimeSynced: lastTimeSynced)
    
    remoteAPI.saveLessonHistory(userID: userID, bookID: bookID, lesson: firebaseLesson)
    
    let firebaseVocabs: [FirebaseVocab] = vocabs.map { vocab in
      let practiceHistory = vocab.practiceHistory
      var firstTimeLearned: Double?
      var lastTimeLearned: Double?
      
      if let fld = practiceHistory.firstLearnDate {
        firstTimeLearned = fld.timeIntervalSince1970
      }
      
      if let ltt = practiceHistory.lastTimeTest {
        lastTimeLearned = ltt.timeIntervalSince1970
      }
      
      return FirebaseVocab(id: vocab.id,
                           isLearned: practiceHistory.isLearned,
                           isMastered: practiceHistory.isMastered,
                           testTaken: practiceHistory.numberOfTestTaken,
                           correctAnswer: practiceHistory.numberOfCorrectAnswer,
                           firstTimeLearned: firstTimeLearned,
                           lastTimeLearned: lastTimeLearned)
    }
    
    remoteAPI.saveVocabHistory(userID: userID, bookID: bookID, lessonID: lessonID, vocabs: firebaseVocabs)
  }
  
}
