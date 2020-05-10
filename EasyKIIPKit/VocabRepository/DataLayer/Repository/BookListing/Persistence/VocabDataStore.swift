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
  func getVocab(by id: Int) -> Vocab?
  func searchVocab(keyword: String) -> [Vocab]
  
  // To Sync With Firestore Cloud
  func syncLessonProficiency(lessonID: Int,
                             proficiency: UInt8,
                             lastTimeSynced: Double)

  func isLessonSynced(_ lessonID: Int) -> Bool
  
  func syncPracticeHistory(vocabID: Int,
                           isMastered: Bool,
                           testTaken: Int,
                           correctAnswer: Int,
                           firstLearnDate: Date?,
                           lastTimeTest: Date?)
}
