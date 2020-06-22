//
//  VocabRemoteAPI.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public struct FirebaseVocab {
  public let id: Int
  public let isLearned: Bool
  public let isMastered: Bool
  public let testTaken: Int
  public let correctAnswer: Int
  /// Time since 1970
  public let firstTimeLearned: Double?
  /// Time since 1970
  public let lastTimeLearned: Double?
  
  public init(id: Int, isLearned: Bool,
              isMastered: Bool,
              testTaken: Int,
              correctAnswer: Int,
              firstTimeLearned: Double?,
              lastTimeLearned: Double?) {
    self.id = id
    self.isLearned = isLearned
    self.isMastered = isMastered
    self.testTaken = testTaken
    self.correctAnswer = correctAnswer
    self.firstTimeLearned = firstTimeLearned
    self.lastTimeLearned = lastTimeLearned
  }
}

public struct FirebaseLesson {
  public let id: Int
  public let proficiency: UInt8
  /// Time since 1970
  public let lastTimeSynced: Double
  public let lastTimeLearned: Double?
  
  public init(id: Int, proficiency: UInt8, lastTimeSynced: Double, lastTimeLearned: Double?) {
    self.id = id
    self.proficiency = proficiency
    self.lastTimeSynced = lastTimeSynced
    self.lastTimeLearned = lastTimeLearned
  }
}

public protocol VocabRemoteAPI {
  func loadLessonData(userID: String, bookID: Int, completion: @escaping ([FirebaseLesson])->())
  func loadVocabData(userID: String, bookID: Int, lessonID: Int, completion: @escaping ([FirebaseVocab])->())
  
  func saveLessonHistory(userID: String, bookID: Int, lesson: FirebaseLesson)
  func saveVocabHistory(userID: String, bookID: Int, lessonID: Int, vocabs: [FirebaseVocab])
}
