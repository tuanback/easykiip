//
//  VocabRemoteAPI.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public struct FirebaseVocab {
  let id: UInt
  let isLearned: Bool
  let isMastered: Bool
  let testTaken: UInt
  let correctAnswer: UInt
  /// Time since 1970
  let firstTimeLearned: Double
  /// Time since 1970
  let lastTimeLearned: Double
}

public struct FirebaseLesson {
  let id: UInt
  let proficiency: UInt8
  /// Time since 1970
  let lastTimeSynced: Double
}

public struct FirebaseBook {
  let id: UInt
  var lessons: [FirebaseLesson]
}

public protocol VocabRemoteAPI {
  func loadBookData(userID: String, bookdID: UInt, completion: ([FirebaseBook])->())
  func loadVocabData(userID: String, lessonID: UInt, completion: ([FirebaseVocab])->())
}
