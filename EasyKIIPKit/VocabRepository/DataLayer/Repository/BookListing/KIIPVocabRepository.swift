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
  
  private var userSessionRepo: UserSessionRepository
  private let remoteAPI: VocabRemoteAPI
  private let dataStore: VocabDataStore
  
  private var userID: String? {
    return userSessionRepo.readUserSession()?.profile.id
  }
  
  private var isPaidUser: Bool {
    return userSessionRepo.isUserSubscribed()
  }
  
  public init(userSessionRepo: UserSessionRepository, remoteAPI: VocabRemoteAPI, dataStore: VocabDataStore) {
    self.userSessionRepo = userSessionRepo
    self.remoteAPI = remoteAPI
    self.dataStore = dataStore
  }
  
  public func getListOfBook() -> [Book] {
    dataStore.getListOfBook()
  }
  
  public func getListOfLesson(inBook id: Int) -> Observable<[Lesson]> {
    // Need to queries from auth remote then merge together
    let userID = self.userID
    let isPaidUser = self.isPaidUser
    let dataStoreLessons = dataStore.getListOfLesson(inBook: id)
    
    return Observable<[Lesson]>.deferred { [weak self] in
      return Observable.create { (observer) -> Disposable in
        
        guard isPaidUser, let uID = userID else {
          observer.onNext(dataStoreLessons)
          return Disposables.create()
        }
        
        self?.remoteAPI.loadLessonData(userID: uID, bookID: id) { [weak self] (lessons) in
          guard let strongSelf = self else { return }
          // Algorithm to merge history from Back end with local datastore
          guard lessons.count > 0 else {
            observer.onNext(dataStoreLessons)
            return
          }
          
          for lesson in lessons {
            self?.dataStore.syncLessonProficiency(lessonID: lesson.id,
                                                  proficiency: lesson.proficiency,
                                                  lastTimeSynced: lesson.lastTimeSynced,
                                                  lastTimeLearned: lesson.lastTimeLearned)
          }
          
          let syncedLessons = strongSelf.dataStore.getListOfLesson(inBook: id)
          observer.onNext(syncedLessons)
        }
        
        return Disposables.create()
      }
    }
  }
  
  public func getLesson(inBook id: Int, lessonID: Int) -> Observable<Lesson> {
    guard let lesson = dataStore.getLesson(by: lessonID) else {
      return Observable.empty()
    }
    
    return getListOfVocabs(inBook: id, inLesson: lessonID)
      .map { (vocabs) in
        lesson.setVocabs(vocabs)
        return lesson
    }
  }
  
  public func getListOfVocabs(inBook bookID: Int, inLesson lessonID: Int) -> Observable<[Vocab]> {
    // Need to queries from auth remote then merge together
    let dataStoreVocabs = dataStore.getListOfVocabs(inLesson: lessonID)
    
    guard isPaidUser, let userID = userID else {
      return .just(dataStoreVocabs)
    }
    
    guard !dataStore.isLessonSynced(lessonID) else {
      return .just(dataStoreVocabs)
    }
    
    return Observable<[Vocab]>.create {  [weak self] (observer) in
      guard let strongSelf = self else {
        observer.onCompleted()
        return Disposables.create()
      }
      
      strongSelf.remoteAPI.loadVocabData(userID: userID,
                                         bookID: bookID,
                                         lessonID: lessonID)
      { (vocabs) in
        guard let strongSelf = self else { return }
        // Algorithm to merge history from Back end with local datastore
        guard vocabs.count > 0 else {
          observer.onNext(dataStoreVocabs)
          return
        }
        
        for vocab in vocabs {
          if let ftl = vocab.firstTimeLearned, let ltt = vocab.lastTimeLearned {
            let first = Date(timeIntervalSince1970: ftl)
            let last = Date(timeIntervalSince1970: ltt)
            
            self?.dataStore.syncPracticeHistory(
              vocabID: vocab.id,
              isMastered: vocab.isMastered,
              testTaken: vocab.testTaken,
              correctAnswer: vocab.correctAnswer,
              firstLearnDate: first,
              lastTimeTest: last)
          }
          else {
            self?.dataStore.syncPracticeHistory(
              vocabID: vocab.id,
              isMastered: vocab.isMastered,
              testTaken: vocab.testTaken,
              correctAnswer: vocab.correctAnswer,
              firstLearnDate: nil,
              lastTimeTest: nil)
          }
        }
        
        let syncedVocabs = strongSelf.dataStore.getListOfVocabs(inLesson: lessonID)
        observer.onNext(syncedVocabs)
      }
      return Disposables.create()
    }
  }
  
  public func markVocabAsMastered(vocabID id: Int) {
    dataStore.markVocabAsMastered(vocabID: id)
  }
  
  public func recordVocabPracticed(vocabID: Int, isCorrectAnswer: Bool) {
    dataStore.recordVocabPracticed(vocabID: vocabID, isCorrectAnswer: isCorrectAnswer)
  }
  
  public func searchVocab(keyword: String) -> [Vocab] {
    return dataStore.searchVocab(keyword: keyword)
  }
  
  public func getListOfLowProficiencyVocab(inBook id: Int, upto numberOfVocabs: Int) -> [Vocab] {
    var vocabs = dataStore.getListOfLesson(inBook: id)
      .flatMap { dataStore.getListOfVocabs(inLesson: $0.id) }
    vocabs = vocabs.filter { $0.practiceHistory.isLearned }
    vocabs.sort { $0.proficiency < $1.proficiency }
    let numberOfElement = min(numberOfVocabs, vocabs.count)
    return Array(vocabs.prefix(upTo: numberOfElement))
  }
  
  public func getListOfLowProficiencyVocab(inLesson id: Int, upto numberOfVocabs: Int) -> [Vocab] {
    var vocabs = dataStore.getListOfVocabs(inLesson: id)
    vocabs = vocabs.filter { $0.practiceHistory.isLearned }
    vocabs.sort { $0.proficiency < $1.proficiency }
    let numberOfElement = min(numberOfVocabs, vocabs.count)
    return Array(vocabs.prefix(upTo: numberOfElement))
  }
  
  public func getNeedReviewVocabs(upto numberOfVocabs: Int) -> [Vocab] {
    let vocabs = getListOfBook()
      .flatMap { dataStore.getListOfLesson(inBook: $0.id)
        .flatMap { dataStore.getListOfVocabs(inLesson: $0.id) }}
    return getNeedReviewVocabs(from: vocabs, upto: numberOfVocabs)
  }
  
  public func getNeedReviewVocabs(inBook id: Int, upto numberOfVocabs: Int) -> [Vocab] {
    let vocabs = dataStore.getListOfLesson(inBook: id)
      .flatMap { dataStore.getListOfVocabs(inLesson: $0.id) }
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
  
  public func saveLessonPracticeHistory(inBook id: Int, lessonID: Int) {
    guard self.isPaidUser, let userID = userID else { return }
    guard let updatedLesson = dataStore.getLesson(by: lessonID) else { return }
    
    let vocabs = dataStore.getNotSyncedVocabsInLesson(lessonID: lessonID)
    
    guard vocabs.count > 0 else {
      return
    }
    
    let lastTimeSynced = Date().timeIntervalSince1970
    let proficiency = updatedLesson.proficiency
    let firebaseLesson = FirebaseLesson(id: lessonID,
                                        proficiency: proficiency,
                                        lastTimeSynced: lastTimeSynced,
                                        lastTimeLearned: updatedLesson.lastTimeLearned?.timeIntervalSince1970)
    
    dataStore.setLessonSynced(lessonID: lessonID, lastTimeSynced: lastTimeSynced)
    
    remoteAPI.saveLessonHistory(userID: userID, bookID: id, lesson: firebaseLesson)
    
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
    
    remoteAPI.saveVocabHistory(userID: userID, bookID: id, lessonID: lessonID, vocabs: firebaseVocabs)
  }
  
  public func getRandomVocabs(differentFromVocabIDs: [Int], upto numberOfVocabs: Int) -> [Vocab] {
    return dataStore.getRandomVocabs(differentFromVocabIDs: differentFromVocabIDs,
                                     upto: numberOfVocabs)
  }
  
}
