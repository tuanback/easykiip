//
//  QuizPracticeViewModelTests.swift
//  EasyKIIPTests
//
//  Created by Real Life Swift on 2020/06/09.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import EasyKIIPKit
@testable import Easy_KIIP

class QuizPracticeViewModelTests: XCTestCase {
 
  func test_init_setQuestionAndOptions() {
    
    let question = PracticeQuestion(vocabID: 1, question: "Q1", options: ["O1", "O2", "O3"], answer: "O1")
    let itemViewModel = QuizItemPracticeViewModel(
      practiceQuestion: question,
      questionText: "Q1",
      optionsDic: ["O1": .notSelected, "O2": .notSelected, "O3": .notSelected])
    let handler = AnswerHandlerStub()
    let sut = QuizPracticeViewModel(quizItemViewModel: itemViewModel,
                                   answerHandler: handler)
    
    let questionSpy = Spy<String>(observable: sut.oQuestion.asObservable())
    let optionSpy = Spy<[String: QuizOptionStatus]>(observable: sut.oOption.asObservable())
    
    XCTAssertEqual(questionSpy.values.last!, "Q1")
    XCTAssertEqual(optionSpy.values.last!, ["O1": .notSelected, "O2": .notSelected, "O3": .notSelected])
  }
  
  func test_updateItemViewModel_containWrongAnswer() {
    
    let question = PracticeQuestion(vocabID: 1, question: "Q1", options: ["O1", "O2", "O3"], answer: "O1")
    let itemViewModel = QuizItemPracticeViewModel(
      practiceQuestion: question,
      questionText: "Q1",
      optionsDic: ["O1": .notSelected, "O2": .notSelected, "O3": .notSelected])
    let handler = AnswerHandlerStub()
    let sut = QuizPracticeViewModel(quizItemViewModel: itemViewModel,
                                   answerHandler: handler)
    
    let questionSpy = Spy<String>(observable: sut.oQuestion.asObservable())
    let optionSpy = Spy<[String: QuizOptionStatus]>(observable: sut.oOption.asObservable())
    let correctViewHidden = Spy<Bool>(observable: sut.oCorrectViewHidden.asObservable())
    let playSoundSpy = Spy<Sound>(observable: sut.oPlaySound)
    
    let newItemViewModel = QuizItemPracticeViewModel(
      practiceQuestion: question,
      questionText: "Q1",
      optionsDic: ["O1": .wrong, "O2": .wrong, "O3": .notSelected])
    
    sut.updateViewModel(quizItemViewModel: newItemViewModel)
    
    XCTAssertEqual(questionSpy.values.last!, "Q1")
    XCTAssertEqual(optionSpy.values.last!, ["O1": .wrong, "O2": .wrong, "O3": .notSelected])
    XCTAssertTrue(correctViewHidden.values.last!)
    XCTAssertEqual(playSoundSpy.values.last!, .wrong)
  }
  
  func test_updateItemViewModel_includeCorrectAnswer_showConfirmationScreen() {
    
    let question = PracticeQuestion(vocabID: 1, question: "Q1", options: ["O1", "O2", "O3"], answer: "O1")
    let itemViewModel = QuizItemPracticeViewModel(
      practiceQuestion: question,
      questionText: "Q1",
      optionsDic: ["O1": .notSelected, "O2": .notSelected, "O3": .notSelected])
    let handler = AnswerHandlerStub()
    let sut = QuizPracticeViewModel(quizItemViewModel: itemViewModel,
                                   answerHandler: handler)
    
    let questionSpy = Spy<String>(observable: sut.oQuestion.asObservable())
    let optionSpy = Spy<[String: QuizOptionStatus]>(observable: sut.oOption.asObservable())
    let correctViewHidden = Spy<Bool>(observable: sut.oCorrectViewHidden.asObservable())
    let playSoundSpy = Spy<Sound>(observable: sut.oPlaySound)
    
    let newItemViewModel = QuizItemPracticeViewModel(
      practiceQuestion: question,
      questionText: "Q1",
      optionsDic: ["O1": .wrong, "O2": .correct, "O3": .wrong])
    
    sut.updateViewModel(quizItemViewModel: newItemViewModel)
    
    XCTAssertEqual(questionSpy.values.last!, "Q1")
    XCTAssertEqual(optionSpy.values.last!, ["O1": .wrong, "O2": .correct, "O3": .wrong])
    XCTAssertFalse(correctViewHidden.values.last!)
    XCTAssertEqual(playSoundSpy.values.last!, .correct)
    
  }
  
  func test_handleAnswer_callAnswerHandler() {
    let question = PracticeQuestion(vocabID: 1, question: "Q1", options: ["O1", "O2", "O3"], answer: "O1")
    let itemViewModel = QuizItemPracticeViewModel(
      practiceQuestion: question,
      questionText: "Q1",
      optionsDic: ["O1": .notSelected, "O2": .notSelected, "O3": .notSelected])
    let handler = AnswerHandlerStub()
    let sut = QuizPracticeViewModel(quizItemViewModel: itemViewModel,
                                   answerHandler: handler)
    
    sut.handleAnswer(answer: "Q1")
    
    XCTAssertTrue(handler.isAnswerHandlerCalled)
  }
  
  // Helpers
  class AnswerHandlerStub: PracticeQuestionAnswerHandler {
    
    var isAnswerHandlerCalled = false
    
    func handleAnswer(for question: PracticeQuestion, answer: String) {
      isAnswerHandlerCalled = true
    }
  }
  
}
