//
//  QuizViewModel.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/07.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit
import Firebase
import RxSwift
import RxCocoa

struct ErrorAction {
  let title: String
  let style: UIAlertAction.Style
  let handler: () -> ()
}

struct AlertWithAction {
  let title: String
  let message: String
  var actions: [ErrorAction] = []
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
  var oHeart: Observable<(Int, Int)> {
    return rHeart.compactMap{ $0 }.asObservable()
  }
  private var rHeart = BehaviorRelay<(Int, Int)?>(value: nil)
  
  var oHeartViewHidden: Driver<Bool> {
    return Observable.merge(
      Observable.just(true),
      rHeart.compactMap{ $0 }.map({ _ in return false })
    )
    .debug()
    .asDriver(onErrorJustReturn: true)
  }
  
  // Child VC
  var oDisplayingChildVC: Observable<QuizItemViewModel> {
    return rDisplayingChildVC.compactMap { $0 }.asObservable()
  }
  private var rDisplayingChildVC = BehaviorRelay<QuizItemViewModel?>(value: nil)
  
  // To show error
  var oAlerts: Observable<AlertWithAction> {
    return rAlerts.compactMap { $0 }.asObservable()
  }
  private var rAlerts = BehaviorRelay<AlertWithAction?>(value: nil)
  
  // To navigate
  var oNavigationEvent: Observable<NavigationEvent<QuizNavigator.Destination>> {
    return rNavigationEvent.compactMap { $0 }.asObservable()
  }
  private var rNavigationEvent = BehaviorRelay<NavigationEvent<QuizNavigator.Destination>?>(value: nil)
  
  private var endQuizAd: GADUnifiedNativeAd?
  
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
      let actionHandler: ()->() = { [weak self] in
        self?.rNavigationEvent.accept(.dismiss)
      }
      let action = ErrorAction(title: Strings.ok,
                               style: .default,
                               handler: actionHandler)
      
      let e = AlertWithAction(title: title,
                              message: message,
                              actions: [action])
      rAlerts.accept(e)
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
    let cancelHandler: ()->() = { }
    let cancelAction = ErrorAction(title: Strings.cancel,
                                   style: .cancel,
                                   handler: cancelHandler)
    let quitHandler: ()->() = { [weak self] in
      self?.rNavigationEvent.accept(.dismiss)
    }
    let quitAction = ErrorAction(title: Strings.quit,
                                 style: .destructive,
                                 handler: quitHandler)
    
    let error = AlertWithAction(title: Strings.quit, message: Strings.areYouSureYouWantToQuit, actions: [cancelAction, quitAction])
    rAlerts.accept(error)
  }
  
  func handleVideoAdsWatchingFinished() {
    quizEngine.refillHeart()
  }
  
  func setEndQuizAd(ad: GADUnifiedNativeAd) {
    endQuizAd = ad
  }
}

extension QuizViewModel: NewWordQuestionAnswerHandler {}
extension QuizViewModel: PracticeQuestionAnswerHandler {}

protocol NewWordQuestionAnswerHandler {
  func handleAnswer(for question: NewWordQuestion)
  func markAsMastered(for question: NewWordQuestion)
}

protocol PracticeQuestionAnswerHandler {
  func handleAnswer(for question: PracticeQuestion, answer: String)
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
    rNavigationEvent.accept(.push(destination: .endQuiz(ad: endQuizAd)))
  }
  
  func quizEngine(numberOfHeart: Int, totalHeart: Int) {
    rHeart.accept((numberOfHeart, totalHeart))
    
    if numberOfHeart == 0 {
      showMessageToWatchVideoToRefillHeart()
    }
  }
  
  private func showMessageToWatchVideoToRefillHeart() {
    let watchAction = ErrorAction(title: Strings.watch, style: .default) { [weak self] in
      self?.rNavigationEvent.accept(.present(destination: .showVideoAds))
    }
    
    let quitAction = ErrorAction(title: Strings.quit, style: .destructive) { [weak self] in
      self?.rNavigationEvent.accept(.dismiss)
    }
    
    let error = AlertWithAction(title: Strings.outOfHeart, message: Strings.youRanOutOfTheHeart, actions: [quitAction, watchAction])
    rAlerts.accept(error)
  }
}
