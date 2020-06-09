//
//  QuizNewWordVC.swift
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

class QuizNewWordVC: XCTestCase {

  func test_init_setWordAndMeaning() {
    
    let question = NewWordQuestion(vocabID: 1,
                                   word: "Word",
                                   meaning: "Meaning")
    let handler = AnswerHandlerStub()
    let sut = QuizNewWordViewModel(question: question,
                                   answerHandler: handler)
    let wordSpy = Spy<String>(observable: sut.oWord.asObservable())
    let meaningSpy = Spy<String>(observable: sut.oMeaning.asObservable())
    
    XCTAssertEqual(wordSpy.values.last!, "Word")
    XCTAssertEqual(meaningSpy.values.last!, "Meaning")
  }
  
  func test_handleLearn_callAnswerHandler_handleAnswer() {
    let question = NewWordQuestion(vocabID: 1,
                                   word: "Word",
                                   meaning: "Meaning")
    let handler = AnswerHandlerStub()
    let sut = QuizNewWordViewModel(question: question,
                                   answerHandler: handler)
    sut.handleAnswer()
    
    XCTAssertTrue(handler.isHandlerAnswerCalled)
  }
  
  func test_handleIsMastered_callAnswerHandler_markAsMastered() {
    let question = NewWordQuestion(vocabID: 1,
                                   word: "Word",
                                   meaning: "Meaning")
    let handler = AnswerHandlerStub()
    let sut = QuizNewWordViewModel(question: question,
                                   answerHandler: handler)
    sut.markAsMastered()
    
    XCTAssertTrue(handler.isMarkAsMasteredCalled)
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
  
  // Helpers
  class AnswerHandlerStub: NewWordQuestionAnswerHandler {
    
    var isHandlerAnswerCalled = false
    var isMarkAsMasteredCalled = false
    
    func handleAnswer(for question: NewWordQuestion) {
      isHandlerAnswerCalled = true
    }
    
    func markAsMastered(for question: NewWordQuestion) {
      isMarkAsMasteredCalled = true
    }
  }
  
}
