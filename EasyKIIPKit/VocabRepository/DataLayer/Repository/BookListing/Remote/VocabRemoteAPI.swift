//
//  VocabRemoteAPI.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public struct FirebaseVocab {
  let id: Int
  let isLearned: Bool
  let isMastered: Bool
  let testTaken: Int
  let correctAnswer: Int
  /// Time since 1970
  let firstTimeLearned: Double
  /// Time since 1970
  let lastTimeLearned: Double
}

public struct FirebaseLesson {
  let id: Int
  let proficiency: UInt8
  /// Time since 1970
  let lastTimeSynced: Double
}

public protocol VocabRemoteAPI {
  func loadLessonData(userID: String, bookdID: Int, completion: @escaping ([FirebaseLesson])->())
  func loadVocabData(userID: String, lessonID: Int, completion: @escaping ([FirebaseVocab])->())
}
