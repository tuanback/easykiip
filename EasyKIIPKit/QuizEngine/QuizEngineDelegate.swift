//
//  QuizEngineDelegate.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/06/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public protocol QuizEngineDelegate {
  func quizEngine(routeTo question: Question)
  func quizEngineDidCompleted()
  func quizEngine(numberOfHeart: Int)
}
