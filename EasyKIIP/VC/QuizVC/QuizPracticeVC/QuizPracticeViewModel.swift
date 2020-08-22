//
//  QuizPracticeViewModel.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/09.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import EasyKIIPKit

enum Sound {
  case correct
  case wrong
  
  var url: URL {
    switch self {
    case .correct:
      return Bundle.main.url(forResource: "correct", withExtension: "wav")!
    default:
      return Bundle.main.url(forResource: "incorrect", withExtension: "wav")!
    }
  }
}

class QuizPracticeViewModel {
  
  var oQuestion: Driver<String> {
    return rQuestion.asDriver()
  }
  
  var oOption: Observable<[String: QuizOptionStatus]> {
    return rOption.asObservable()
  }
  
  var oCorrectViewHidden: Observable<Bool> {
    return rCorrectViewHidden.asObservable()
  }
  
  var oPlaySound: Observable<Sound> {
    return rPlaySound.asObservable()
  }
  
  var oSpeak: Observable<String> {
    return rSpeak.asObservable()
  }
  
  private let rQuestion: BehaviorRelay<String>
  private let rOption: BehaviorRelay<[String: QuizOptionStatus]>
  private let rCorrectViewHidden = BehaviorRelay<Bool>(value: true)
  private let rPlaySound = PublishRelay<Sound>()
  private let rSpeak = PublishRelay<String>()
  
  private var question: PracticeQuestion
  private let answerHandler: PracticeQuestionAnswerHandler
  
  init(quizItemViewModel: QuizItemPracticeViewModel,
       answerHandler: PracticeQuestionAnswerHandler) {
    self.question = quizItemViewModel.practiceQuestion
    self.rQuestion = BehaviorRelay<String>(value: quizItemViewModel.questionText)
    self.rOption = BehaviorRelay<[String: QuizOptionStatus]>(value: quizItemViewModel.optionsDic)
    self.answerHandler = answerHandler
  }
  
  func handleQuestionDidAppear() {
    if question.isQuestionKorean {
      rSpeak.accept(rQuestion.value)
    }
  }
  
  func updateViewModel(quizItemViewModel: QuizItemPracticeViewModel) {
    self.question = quizItemViewModel.practiceQuestion
    self.rQuestion.accept(quizItemViewModel.questionText)
    self.rOption.accept(quizItemViewModel.optionsDic)
    
    if let _ = quizItemViewModel.optionsDic.first(where: { $0.value == .correct
    }) {
      rCorrectViewHidden.accept(false)
      rPlaySound.accept(.correct)
      return
    }
    
    if let _ = quizItemViewModel.optionsDic.first(where: { $0.value == .wrong
    }) {
      rPlaySound.accept(.wrong)
      return
    }
    
    if quizItemViewModel.optionsDic.filter({ $0.value != .notSelected }).count == 0 {
      handleQuestionDidAppear()
    }
  }
  
  func handleAnswer(answer: String) {
    answerHandler.handleAnswer(for: question, answer: answer)
  }
  
}
