//
//  QuizEngine.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/06/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public protocol QuizEngine {
  func start()
  func handleAnswer(for question: Question, answer: String?)
  func markAsMastered(for question: Question)
}

