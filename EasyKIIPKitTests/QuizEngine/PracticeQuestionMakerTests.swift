//
//  PracticeQuestionMakerTests.swift
//  EasyKIIPKitTests
//
//  Created by Tuan on 2020/06/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
@testable import EasyKIIPKit

class PracticeQuestionMakerTests: XCTestCase {
  
  let vocab1 = Vocab(id: 1, word: "안녕!", translations: [.en: "Hello", .vi: "Xin chào"])
  let vocab2 = Vocab(id: 2, word: "감사합니다!", translations: [.en: "Thank you", .vi: "Cảm ơn"])
  let vocab3 = Vocab(id: 3, word: "어제", translations: [.en: "Yesterday", .vi: "Hôm qua"])
  let vocab4 = Vocab(id: 4, word: "오늘", translations: [.en: "Today", .vi: "Hôm nay"])
  let vocab5 = Vocab(id: 5, word: "크다", translations: [.en: "Big", .vi: "To"])
  let vocab6 = Vocab(id: 6, word: "작다", translations: [.en: "Small", .vi: "Nhỏ"])
  let vocab7 = Vocab(id: 7, word: "추다", translations: [.en: "Cold", .vi: "Lạnh"])
  let vocab8 = Vocab(id: 8, word: "덥다", translations: [.en: "Hot", .vi: "Nóng"])
  let vocab9 = Vocab(id: 9, word: "높다", translations: [.en: "High", .vi: "Cao"])
  let vocab10 = Vocab(id: 10, word: "낮다", translations: [.en: "Low", .vi: "Thấp"])
  let vocab11 = Vocab(id: 11, word: "예쁘다", translations: [.en: "Beautiful", .vi: "Đẹp"])
  
  func test_inputEmptyVocabs_createQuestionEmpty() {
    
    let sut = makeSut(createQuestionVocabs: [],
                      randomVocabs: [],
                      languageCode: .vi)
    
    let questions = sut.createQuestions()
    XCTAssertEqual(questions.count, 0)
  }
  
  func test_input1Vocab_1randomVocab_notLearn_create3Questions() {
    let sut = makeSut(createQuestionVocabs: [vocab1],
                      randomVocabs: [vocab2],
                      languageCode: .vi)
    let questions = sut.createQuestions()
    XCTAssertEqual(questions.count, 0)
  }
  
  func test_input1Vocab_1randomVocab_learnt_create2Questions() {
    let sut = makeSut(createQuestionVocabs: [vocab1],
                      randomVocabs: [vocab2],
                      languageCode: .vi)
    vocab1.increaseNumberOfCorrectAnswerByOne()
    let questions = sut.createQuestions()
    XCTAssertEqual(questions.count, 2)
  }
  
  func test_input1Vocab_1randomVocab_mastered_createQuestionsEmpty() {
    let sut = makeSut(createQuestionVocabs: [vocab1],
                      randomVocabs: [vocab2],
                      languageCode: .vi)
    vocab1.markAsIsMastered()
    let questions = sut.createQuestions()
    XCTAssertEqual(questions.count, 0)
  }
  
  func test_createANewQuestion_returnDifferenceQuestion() {
    let sut = makeSut(createQuestionVocabs: [vocab1],
                      randomVocabs: [vocab2],
                      languageCode: .vi)
    
    vocab1.increaseNumberOfCorrectAnswerByOne()
    let questions = sut.createQuestions()
    let question = sut.createANewQuestion(for: questions[1])
    
    XCTAssertNotEqual(questions[1], question)
  }
  
  func test_input2Vocabs_2randomVocabs_learnt_create4Questions() {
    let sut = makeSut(createQuestionVocabs: [vocab1, vocab2],
                      randomVocabs: [vocab3, vocab4],
                      languageCode: .vi)

    vocab1.increaseNumberOfCorrectAnswerByOne()
    vocab2.increaseNumberOfCorrectAnswerByOne()
    let questions = sut.createQuestions()
    XCTAssertEqual(questions.count, 4)
  }
  
  private func makeSut(createQuestionVocabs: [Vocab],
                       randomVocabs: [Vocab],
                       languageCode: LanguageCode) -> PracticeQuestionMaker {
    return PracticeQuestionMaker(createQuestionVocabs: createQuestionVocabs,
                                 randomVocabs: randomVocabs,
                                 languageCode: languageCode)
  }
  
}
