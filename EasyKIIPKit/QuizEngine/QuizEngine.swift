//
//  QuizEngine.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/06/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public protocol QuizEngine: class {
  var delegate: QuizEngineDelegate? { get set }
  
  func start() throws
  func handleAnswer(for question: Question, answer: String?)
  func markAsMastered(for question: Question)
  func refillHeart()
}

