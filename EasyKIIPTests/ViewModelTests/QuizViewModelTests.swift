//
//  QuizViewModel.swift
//  QuizViewModelTests
//
//  Created by Tuan on 2020/06/07.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import EasyKIIPKit
import RxSwift
import RxCocoa
@testable import Easy_KIIP

class QuizViewModelTests: XCTestCase {

  func test_init_isQuizEngineDelegate() {
    
    let (sut, quizEngine) = makeSut(questions: [])
    
    XCTAssertNotNil(quizEngine.delegate)
  }
  
  func test_init_quizEngineStartCalled() {
    let (sut, quizEngine) = makeSut(questions: [])
    
    XCTAssertTrue(quizEngine.isStartCalled)
  }
 
  func test_int_noQuestion_error_clickButton_Dismiss() {
    let (sut, _) = makeSut(questions: [])
    let errorSpy = ErrorSpy(observable: sut.oAlerts)
    let navigationSpy = NavigationSpy(observable: sut.oNavigationEvent)
    
    XCTAssertEqual(errorSpy.errors.count, 1)
    XCTAssertEqual(navigationSpy.navigationEvents.count, 1)
  }
  
  func test_init_oneNewWordQuestion_navigateToFirstQuestion() {
    let question = Question.newWord(NewWordQuestion(vocabID: 1, word: "Q1", meaning: "A1"))
    let (sut, _) = makeSut(questions: [question])
    
    let displayingVCSpy = DisplayingVCSpy(observable: sut.oDisplayingChildVC)
    
    XCTAssertEqual(displayingVCSpy.vcs.count, 1)
    if case .newWord(_) = displayingVCSpy.vcs[0] { }
    else {
      XCTFail()
    }
  }
  
  func test_init_onePracticeQuestion_navigateToFirstQuestion() {
    let question = Question.practice(PracticeQuestion(vocabID: 1,
                                                      question: "Q1",
                                                      options: ["O1", "O2", "O3"],
                                                      answer: "A1"))
    let (sut, _) = makeSut(questions: [question])
    
    let displayingVCSpy = DisplayingVCSpy(observable: sut.oDisplayingChildVC)
    
    XCTAssertEqual(displayingVCSpy.vcs.count, 1)
    if case .practice(_) = displayingVCSpy.vcs[0] { }
    else {
      XCTFail()
    }
  }
  
  func test_init_oneNewWordQuestion_handleQuestionAnswer_callQuizEngine() {
    let newWordQuestion = NewWordQuestion(vocabID: 1, word: "Q1", meaning: "A1")
    let question = Question.newWord(newWordQuestion)
    let (sut, quizEngine) = makeSut(questions: [question])
    
    sut.handleAnswer(for: newWordQuestion)
    
    XCTAssertTrue(quizEngine.isHandleAnswerCalled)
  }
  
  func test_init_oneNewWordQuestion_handleMarkAsMastered_callQuizEngine() {
    let newWordQuestion = NewWordQuestion(vocabID: 1, word: "Q1", meaning: "A1")
    let question = Question.newWord(newWordQuestion)
    let (sut, quizEngine) = makeSut(questions: [question])
    
    sut.markAsMastered(for: newWordQuestion)
    
    XCTAssertTrue(quizEngine.isMarkAsMastered)
  }
  
  func test_init_onePracticeQuestion_handleQuestionAnswer_callQuizEngine() {
    let practiceQuestion = PracticeQuestion(vocabID: 1,
                                            question: "Q1",
                                            options: ["O1", "O2", "O3"],
                                            answer: "A1")
    let question = Question.practice(practiceQuestion)
    let (sut, quizEngine) = makeSut(questions: [question])
    
    sut.handleAnswer(for: practiceQuestion, answer: "A1")
    
    XCTAssertTrue(quizEngine.isHandleAnswerCalled)
  }
  
  func test_init_heartViewHidden_true() {
    let (sut, _) = makeSut(questions: [])
    let heartViewHidden: Spy<Bool> = Spy<Bool>(observable: sut.oHeartViewHidden.asObservable())
    XCTAssertEqual(heartViewHidden.values, [true])
  }
  
  func test_init_handleNumberOfHeart() {
    let (sut, quizEngine) = makeSut(questions: [])
    let heartSpy: Spy<(Int, Int)> = Spy<(Int, Int)>(observable: sut.oHeart)
    let heartViewHidden: Spy<Bool> = Spy<Bool>(observable: sut.oHeartViewHidden.asObservable())
    quizEngine.outputNumberOfHeart(heart: 3, totalHeart: 3)
    XCTAssertEqual(heartSpy.values[0].0, 3)
    XCTAssertEqual(heartSpy.values[0].1, 3)
    XCTAssertEqual(heartViewHidden.values, [true, false])
  }
  
  func test_completeQuiz_navigateToNextVC() {
    let (sut, quizEngine) = makeSut(questions: [])
    let navigationEvent = NavigationSpy(observable: sut.oNavigationEvent)
    quizEngine.completeQuiz()
    
    if case .push(let destination) = navigationEvent.navigationEvents[0] {
      if destination != .endQuiz {
        XCTFail()
      }
    }
    else {
      XCTFail()
    }
  }
  
  func test_handleClose_askUserToConfirm() {
    let newWordQuestion = NewWordQuestion(vocabID: 1, word: "Q1", meaning: "A1")
    let question = Question.newWord(newWordQuestion)
    let (sut, _) = makeSut(questions: [question])
    let errorSpy = ErrorSpy(observable: sut.oAlerts)
    let navigationSpy = NavigationSpy(observable: sut.oNavigationEvent)
    
    sut.handleClose()
    
    XCTAssertEqual(errorSpy.errors.count, 1)
    if case .dismiss = navigationSpy.navigationEvents[0] { }
    else {
      XCTFail()
    }
  }
  
  func test_outOfHeart_showMessageToViewAds() {
    let newWordQuestion = NewWordQuestion(vocabID: 1, word: "Q1", meaning: "A1")
    let question = Question.newWord(newWordQuestion)
    let (sut, quizEngine) = makeSut(questions: [question])
    let errorSpy = ErrorSpy(observable: sut.oAlerts)
    let navigationSpy = NavigationSpy(observable: sut.oNavigationEvent)
    
    quizEngine.outputNumberOfHeart(heart: 0, totalHeart: 3)
    
    XCTAssertEqual(errorSpy.errors.count, 1)
    if case .present(let destination) = navigationSpy.navigationEvents[0] {
      if destination != .showVideoAds {
        XCTFail()
      }
    }
    else {
      XCTFail()
    }
  }
  
  func test_finishWatchingVideoAds_refillHeart() {
    
    let newWordQuestion = NewWordQuestion(vocabID: 1, word: "Q1", meaning: "A1")
    let question = Question.newWord(newWordQuestion)
    let (sut, quizEngine) = makeSut(questions: [question])
    sut.handleVideoAdsWatchingFinished()
    
    XCTAssertTrue(quizEngine.isRefillHeartCalled)
  }
  
  func test_answerWrong_updateDisplayingVCViewModel() {
    let practiceQuestion = PracticeQuestion(vocabID: 1,
                                            question: "Q1",
                                            options: ["A1", "A2", "A3"],
                                            answer: "A1")
    let question = Question.practice(practiceQuestion)
    let (sut, _) = makeSut(questions: [question])
    
    let displayingVCSpy = DisplayingVCSpy(observable: sut.oDisplayingChildVC)
    
    sut.handleAnswer(for: practiceQuestion, answer: "A2")
    
    if let lastVM = displayingVCSpy.vcs.last {
      switch lastVM {
      case .practice(let viewModel):
        for option in viewModel.optionsDic {
          if option.key != "A2" && (option.value == .correct || option.value == .wrong) {
            XCTFail()
          }
          
          if option.key == "A2" && option.value != .wrong {
            XCTFail()
          }
        }
      default:
        XCTFail()
      }
    }
    
  }
  
  func test_answerCorrect_updateDisplayingVCViewModel() {
    let practiceQuestion = PracticeQuestion(vocabID: 1,
                                            question: "Q1",
                                            options: ["A1", "A2", "A3"],
                                            answer: "A1")
    let question = Question.practice(practiceQuestion)
    let (sut, _) = makeSut(questions: [question])
    
    let displayingVCSpy = DisplayingVCSpy(observable: sut.oDisplayingChildVC)
    
    sut.handleAnswer(for: practiceQuestion, answer: "A1")
    
    if let lastVM = displayingVCSpy.vcs.last {
      switch lastVM {
      case .practice(let viewModel):
        for option in viewModel.optionsDic {
          if option.key != "A1" && (option.value == .correct || option.value == .wrong) {
            XCTFail()
          }
          
          if option.key == "A1" && option.value != .correct {
            XCTFail()
          }
        }
      default:
        XCTFail()
      }
    }
    
  }
  
  func test_answer2TimesWrong_1TimeCorrect_updateDisplayingVCViewModel() {
    let practiceQuestion = PracticeQuestion(vocabID: 1,
                                            question: "Q1",
                                            options: ["A1", "A2", "A3"],
                                            answer: "A1")
    let question = Question.practice(practiceQuestion)
    let (sut, _) = makeSut(questions: [question])
    
    let displayingVCSpy = DisplayingVCSpy(observable: sut.oDisplayingChildVC)
    
    sut.handleAnswer(for: practiceQuestion, answer: "A2")
    sut.handleAnswer(for: practiceQuestion, answer: "A3")
    sut.handleAnswer(for: practiceQuestion, answer: "A1")
    
    if let lastVM = displayingVCSpy.vcs.last {
      switch lastVM {
      case .practice(let viewModel):
        for option in viewModel.optionsDic {
          if option.key == "A2" && option.value != .wrong {
            XCTFail()
          }
          
          if option.key == "A3" && option.value != .wrong {
            XCTFail()
          }
          
          if option.key == "A1" && option.value != .correct {
            XCTFail()
          }
        }
      default:
        XCTFail()
      }
    }
    
  }
  
  // Helpers:
  private func makeSut(questions: [Question]) -> (QuizViewModel, QuizEngineStub) {
    let quizEngine = QuizEngineStub(questions: questions)
    let sut = QuizViewModel(quizEngine: quizEngine)
    return (sut, quizEngine)
  }
  
  class Spy<T> {
    private(set) var values: [T] = []
    
    private let disposeBag = DisposeBag()
    
    init(observable: Observable<T>) {
      
      observable
        .subscribe(onNext: { [weak self] value in
          self?.values.append(value)
        })
        .disposed(by: disposeBag)
    }
  }
  
  class DisplayingVCSpy {
    
    private(set) var vcs: [QuizItemViewModel] = []
    
    private let disposeBag = DisposeBag()
    
    init(observable: Observable<QuizItemViewModel>) {
      
      observable
        .subscribe(onNext: { [weak self] vc in
          self?.vcs.append(vc)
        })
        .disposed(by: disposeBag)
    }
  }
  
  class ErrorSpy {
    
    private(set) var errors: [AlertWithAction] = []
    private let disposeBag = DisposeBag()
    
    init(observable: Observable<AlertWithAction>) {
      
      observable
        .subscribe(onNext: { [weak self] error in
          self?.errors.append(error)
          if let action = error.actions.first(where: { $0.style == .default }) {
            action.handler()
          }
          else if let action = error.actions.first(where: { $0.style == .destructive }) {
            action.handler()
          }
        })
        .disposed(by: disposeBag)
    }
  }
  
  class NavigationSpy {
    
    private(set) var navigationEvents: [NavigationEvent<QuizNavigator.Destination>] = []
    
    private let disposeBag = DisposeBag()
    
    init(observable: Observable<NavigationEvent<QuizNavigator.Destination>>) {
      
      observable
        .subscribe(onNext: { [weak self] event in
          self?.navigationEvents.append(event)
        })
        .disposed(by: disposeBag)
    }
  }
  
  class QuizEngineStub: QuizEngine {
    
    weak var delegate: QuizEngineDelegate?
    
    var isStartCalled = false
    var isMarkAsMastered = false
    var isHandleAnswerCalled = false
    var isRefillHeartCalled = false
    
    private let questions: [Question]
    
    init(questions: [Question]) {
      self.questions = questions
    }
    
    func start() throws {
      isStartCalled = true
      guard questions.count > 0 else {
        throw QuizEngineError.noQuestion
      }
      delegate?.quizEngine(routeTo: questions[0])
    }
    
    func handleAnswer(for question: Question, answer: String?) {
      isHandleAnswerCalled = true
      
      if case let .practice(q) = question, let ans = answer {
        if ans == q.answer {
          delegate?.quizEngine(correctAnswerFor: question, answer: ans)
        }
        else {
          delegate?.quizEngine(wrongAnswerFor: question, answer: ans)
        }
      }
    }
    
    func markAsMastered(for question: Question) {
      isMarkAsMastered = true
    }
    
    func outputNumberOfHeart(heart: Int, totalHeart: Int) {
      delegate?.quizEngine(numberOfHeart: heart, totalHeart: totalHeart)
    }
    
    func completeQuiz() {
      delegate?.quizEngineDidCompleted()
    }
    
    func refillHeart() {
      isRefillHeartCalled = true
    }
  }
  
}
