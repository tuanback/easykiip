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
  func getListOfLesson(inBook id: Int) -> [Lesson]
  func getListOfVocabs(inLesson id: Int) -> [Vocab]
  func markVocabAsMastered(vocabID id: Int)
  func recordVocabPracticed(vocabID: Int, isCorrectAnswer: Bool)
  func getLesson(by id: Int) -> Lesson?
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
  
  func getNotSyncedVocabsInLesson(lessonID: Int) -> [Vocab]
  func setLessonSynced(lessonID: Int, lastTimeSynced: Double)
}
