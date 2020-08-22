//
//  QuizNewWordViewModel.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/09.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import EasyKIIPKit

class QuizNewWordViewModel {
  
  var oWord: Driver<String> {
    return rWord.asDriver()
  }
  
  var oMeaning: Driver<String> {
    return rMeaning.asDriver()
  }
  
  var oSpeak: Observable<String> {
    return rSpeak.asObservable()
  }
  
  var oPlaySound: Observable<Sound> {
    return rPlaySound.asObservable()
  }
  
  private let rWord: BehaviorRelay<String>
  private let rMeaning: BehaviorRelay<String>
  private let rSpeak = PublishRelay<String>()
  private let rPlaySound = PublishRelay<Sound>()
  private let question: NewWordQuestion
  private let answerHandler: NewWordQuestionAnswerHandler
  
  init(question: NewWordQuestion, answerHandler: NewWordQuestionAnswerHandler) {
    self.question = question
    self.rWord = BehaviorRelay<String>(value: question.word)
    self.rMeaning = BehaviorRelay<String>(value: question.meaning)
    self.answerHandler = answerHandler
  }
  
  func handleViewDidAppear() {
    rSpeak.accept(rWord.value)
  }
  
  func handleAnswer() {
    rPlaySound.accept(.correct)
    answerHandler.handleAnswer(for: question)
  }
  
  func markAsMastered() {
    rPlaySound.accept(.correct)
    answerHandler.markAsMastered(for: question)
  }
  
}
