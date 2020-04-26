//
//  KIIPVocabRepository.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import SwiftDate

public class KIIPVocabRepository: VocabRepository {
  
  private let remoteAPI: VocabRemoteAPI
  private let dataStore: VocabDataStore
  
  init(remoteAPI: VocabRemoteAPI, dataStore: VocabDataStore) {
    self.remoteAPI = remoteAPI
    self.dataStore = dataStore
  }
  
  public func syncUserData() {
    // TODO: There should have a condition to init the load practice history
    // Condition can be
    // + Just install the app in the current device
    // + User log out then just log in again
    // +
    initSyncPracticeHistory()
  }
  
  private func initSyncPracticeHistory() {
    remoteAPI.loadPracticeHistory { [weak self] (practiceHistories) -> (Void) in
      guard let strongSelf = self else { return }
      // TODO: Handle practice history
      for history in practiceHistories {
        guard let firstLearnDate = history.firstLearnDate,
          let lastTimeTest = history.lastTimeTest else { continue }
        
        strongSelf.dataStore.syncPracticeHistory(vocabID: history.id, testTaken: history.numberOfTestTaken, correctAnswer: history.numberOfCorrectAnswer, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
      }
    }
  }
  
  public func getListOfBook() -> [Book] {
    dataStore.getListOfBook()
  }
  
  public func getListOfLesson(in book: Book) -> [Lesson] {
    dataStore.getListOfLesson(in: book)
  }
  
  public func getListOfVocabs(in lesson: Lesson) -> [Vocab] {
    dataStore.getListOfVocabs(in: lesson)
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
    var vocabs = getListOfLesson(in: book).flatMap { getListOfVocabs(in: $0) }
    vocabs = vocabs.filter { $0.practiceHistory.isLearned }
    vocabs.sort { $0.proficiency < $1.proficiency }
    let numberOfElement = min(numberOfVocabs, vocabs.count)
    return Array(vocabs.prefix(upTo: numberOfElement))
  }
  
  public func getListOfLowProficiencyVocab(in lession: Lesson, upto numberOfVocabs: Int) -> [Vocab] {
    var vocabs = getListOfVocabs(in: lession)
    vocabs = vocabs.filter { $0.practiceHistory.isLearned }
    vocabs.sort { $0.proficiency < $1.proficiency }
    let numberOfElement = min(numberOfVocabs, vocabs.count)
    return Array(vocabs.prefix(upTo: numberOfElement))
  }
  
  public func getNeedReviewVocabs(upto numberOfVocabs: Int) -> [Vocab] {
    let vocabs = getListOfBook().flatMap { getListOfLesson(in: $0).flatMap { getListOfVocabs(in: $0) }}
    return getNeedReviewVocabs(from: vocabs, upto: numberOfVocabs)
  }
  
  public func getNeedReviewVocabs(in book: Book, upto numberOfVocabs: Int) -> [Vocab] {
    let vocabs = getListOfLesson(in: book).flatMap { getListOfVocabs(in: $0) }
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
  
}