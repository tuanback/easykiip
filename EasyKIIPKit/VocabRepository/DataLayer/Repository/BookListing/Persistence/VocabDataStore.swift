//
//  VocabDataStore.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public protocol VocabDataStore {
  func getListOfBook() -> [Book]
  func getListOfLesson(in book: Book) -> [Lesson]
  func getListOfVocabs(in lesson: Lesson) -> [Vocab]
  func markVocabAsMastered(_ vocab: Vocab)
  func recordVocabPracticed(vocab: Vocab, isCorrectAnswer: Bool)
  func getVocab(by id: UInt) -> Vocab?
  func searchVocab(keyword: String) -> [Vocab]
  
  // To Sync With Firestore Cloud
  func syncLessonProficiency(lessonID: UInt,
                             proficiency: UInt8,
                             lastTimeSynced: Double)
  
  func syncPracticeHistory(vocabID: UInt,
                           isMastered: Bool,
                           testTaken: UInt,
                           correctAnswer: UInt,
                           firstLearnDate: Date,
                           lastTimeTest: Date)
}
