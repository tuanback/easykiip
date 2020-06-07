//
//  QuizViewModel.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/07.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit
import RxSwift
import RxCocoa

struct ErrorWithCompletion {
  let title: String
  let message: String
  var completion: (()->())?
}

extension QuizEngineError {
  func toString() -> (String, String) {
    switch self {
    case .noQuestion:
      return (Strings.nothingNeedMorePractice, Strings.youAreMasteredAllVocabularies)
    }
  }
}

enum QuizOptionStatus {
  case notSelected
  case wrong
  case correct
}

struct QuizItemPracticeViewModel {
  let practiceQuestion: PracticeQuestion
  let questionText: String
  var optionsDic: [String: QuizOptionStatus]
}

enum QuizItemViewModel {
  case newWord(NewWordQuestion)
  case practice(QuizItemPracticeViewModel)
}

class QuizViewModel {
  
  // Heart
  var oHeart: Observable<Int> {
    return rHeart.asObservable()
  }
  private var rHeart = PublishRelay<Int>()
  
  var oHeartViewHidden: Observable<Bool> {
    return Observable.merge(
      Observable.just(true),
      rHeart.map({ _ in return false })
    )
  }
  
  // Child VC
  var oDisplayingChildVC: Observable<QuizItemViewModel> {
    return rDisplayingChildVC.compactMap { $0 }.asObservable()
  }
  private var rDisplayingChildVC = BehaviorRelay<QuizItemViewModel?>(value: nil)
  
  // To show error
  var oErrors: Observable<ErrorWithCompletion> {
    return rErrors.compactMap { $0 }.asObservable()
  }
  private var rErrors = BehaviorRelay<ErrorWithCompletion?>(value: nil)
  
  // To navigate
  var oNavigationEvent: Observable<NavigationEvent<QuizNavigator.Destination>> {
    return rNavigationEvent.compactMap { $0 }.asObservable()
  }
  private var rNavigationEvent = BehaviorRelay<NavigationEvent<QuizNavigator.Destination>?>(value: nil)
  
  private let quizEngine: QuizEngine
  
  init(quizEngine: QuizEngine) {
    self.quizEngine = quizEngine
    self.quizEngine.delegate = self
    self.startQuizEngine()
  }
  
  private func startQuizEngine() {
    do {
      try self.quizEngine.start()
    }
    catch {
      // Inform user that no question => navigate back to previous page
      guard let error = error as? QuizEngineError else { return }
      let (title, message) = error.toString()
      let e = ErrorWithCompletion(title: title, message: message, completion: { [weak self] in
        self?.rNavigationEvent.accept(.dismiss)
      })
      rErrors.accept(e)
    }
  }
  
  func handleAnswer(for question: NewWordQuestion) {
    let q = Question.newWord(question)
    quizEngine.handleAnswer(for: q, answer: "")
  }
  
  func handleAnswer(for question: PracticeQuestion, answer: String) {
    let q = Question.practice(question)
    quizEngine.handleAnswer(for: q, answer: answer)
  }
  
  func markAsMastered(for question: NewWordQuestion) {
    let q = Question.newWord(question)
    quizEngine.markAsMastered(for: q)
  }
  
  func handleClose() {
    let error = ErrorWithCompletion(title: Strings.quit, message: Strings.areYouSureYouWantToQuit) { [weak self] in
      self?.rNavigationEvent.accept(.dismiss)
    }
    rErrors.accept(error)
  }
  
  func handleVideoAdsWatchingFinished() {
    quizEngine.refillHeart()
  }
  
}

extension QuizViewModel: QuizEngineDelegate {
  
  func quizEngine(routeTo question: Question) {
    switch question {
    case .newWord(let q):
      rDisplayingChildVC.accept(.newWord(q))
    case .practice(let q):
      let question = q.question
      var optionsDic: [String: QuizOptionStatus] = [:]
      for option in q.options {
        optionsDic[option] = .notSelected
      }
      let viewModel = QuizItemPracticeViewModel(practiceQuestion: q, questionText: question, optionsDic: optionsDic)
      rDisplayingChildVC.accept(.practice(viewModel))
    }
  }
  
  func quizEngine(correctAnswerFor question: Question, answer: String) {
    guard let vc = rDisplayingChildVC.value,
      case let .practice(viewModel) = vc else { return }
    
    var vm = viewModel
    vm.optionsDic[answer] = .correct
    rDisplayingChildVC.accept(.practice(vm))
  }
  
  func quizEngine(wrongAnswerFor question: Question, answer: String) {
    guard let vc = rDisplayingChildVC.value,
      case let .practice(viewModel) = vc else { return }
    
    var vm = viewModel
    vm.optionsDic[answer] = .wrong
    rDisplayingChildVC.accept(.practice(vm))
  }
  
  func quizEngineDidCompleted() {
    rNavigationEvent.accept(.push(destination: .endQuiz))
  }
  
  func quizEngine(numberOfHeart: Int) {
    guard numberOfHeart > 0 else {
      showMessageToWatchVideoToRefillHeart()
      return
    }
    rHeart.accept(numberOfHeart)
  }
  
  private func showMessageToWatchVideoToRefillHeart() {
    let error = ErrorWithCompletion(title: Strings.outOfHeart, message: Strings.youRanOutOfTheHeart) { [weak self] in
      self?.rNavigationEvent.accept(.present(destination: .showVideoAds))
    }
    rErrors.accept(error)
  }
}
