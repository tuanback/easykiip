//
//  KIIPVocabRepository.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class KIIPVocabRepository: VocabRepository {
  
  private let remoteAPI: VocabRemoteAPI
  private let dataStore: VocabDataStore
  
  init(remoteAPI: VocabRemoteAPI, dataStore: VocabDataStore) {
    self.remoteAPI = remoteAPI
    self.dataStore = dataStore
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
  
  public func searchVocab(keywork: String) -> [Vocab] {
    return []
  }
  
  public func getListOfLowProficiencyVocab(in book: Book, upto numberOfVocabs: Int) -> [Vocab] {
    return []
  }
  
  public func getListOfLowProficiencyVocab(in lession: Lesson, upto numberOfVocabs: Int) -> [Vocab] {
    return []
  }
  
  public func getNeedReviewVocabs(upto numberOfVocabs: Int) -> [Vocab] {
    return []
  }
  
  public func getNeedReviewVocabs(in book: Book, upto numberOfVocabs: Int) -> [Vocab] {
    return []
  }
  
}
