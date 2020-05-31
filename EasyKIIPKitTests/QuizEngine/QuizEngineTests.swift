//
//  QuizEngineTests.swift
//  EasyKIIPKitTests
//
//  Created by Tuan on 2020/05/31.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

public protocol QuizEngine {
  func start() throws
}

public protocol QuizEngineDelegate {
  func routeToQuestion(question: String)
}

enum QuizEngineError: LocalizedError {
  case noQuestion
}

public protocol QuestionMaker {
  func createQuestions() -> [String]
}

public class KIIPQuizEngine: QuizEngine {
  
  private let questionMaker: QuestionMaker
  private let vocabRepository: VocabRepository
  private let delegate: QuizEngineDelegate
  
  private var questions: [String] = []
  
  public init(questionMaker: QuestionMaker,
              vocabRepository: VocabRepository,
              delegate: QuizEngineDelegate) {
    self.questionMaker = questionMaker
    self.vocabRepository = vocabRepository
    self.delegate = delegate
    self.questions = questionMaker.createQuestions()
  }
  
  public func start() throws {
    guard self.questions.count > 0 else {
      throw QuizEngineError.noQuestion
    }
    
    let question = self.questions[0]
    delegate.routeToQuestion(question: question)
  }
}

class QuizEngineTests: XCTestCase {
  
  func test_start_noQuestion_throwsNoQuestionsError() throws {
    
    let vocabRepository = VocabRepositoryStub()
    let questionMaker = QuestionMakerStub(questions: [])
    let delegate = QuizEngineDelegateSpy()
    let sut = KIIPQuizEngine(questionMaker: questionMaker,
                             vocabRepository: vocabRepository,
                             delegate: delegate)
    XCTAssertThrowsError(try sut.start())
  }
  
  func test_start_withOneQuestion_routeToFirstQuestion() throws {
    let vocabRepository = VocabRepositoryStub()
    let questionMaker = QuestionMakerStub(questions: ["Q1"])
    let delegate = QuizEngineDelegateSpy()
    let sut = KIIPQuizEngine(questionMaker: questionMaker,
                             vocabRepository: vocabRepository,
                             delegate: delegate)
    try sut.start()
    
    XCTAssertEqual(delegate.questions, ["Q1"])
  }
  
  
  // Helpers
  class QuestionMakerStub: QuestionMaker {
    
    private(set) var questions: [String]
    
    init(questions: [String]) {
      self.questions = questions
    }
    
    func createQuestions() -> [String] {
      return self.questions
    }
  }

  class QuizEngineDelegateSpy: QuizEngineDelegate {
    private(set) var questions: [String] = []
    
    init() {
      
    }
    
    func routeToQuestion(question: String) {
      self.questions.append(question)
    }
  }
  
  
  class VocabRepositoryStub: VocabRepository {
    func getListOfBook() -> [Book] {
      return []
    }
    
    func getListOfLesson(inBook id: Int) -> Observable<[Lesson]> {
      return .just([])
    }
    
    func getLesson(inBook id: Int, lessonID: Int) -> Observable<Lesson> {
      return .empty()
    }
    
    func getListOfVocabs(inBook bookID: Int, inLesson lessonID: Int) -> Observable<[Vocab]> {
      return .just([])
    }
    
    func markVocabAsMastered(vocabID id: Int) {
      
    }
    
    func recordVocabPracticed(vocabID: Int, isCorrectAnswer: Bool) {
      
    }
    
    func saveLessonPracticeHistory(inBook id: Int, lessonID: Int) {
      
    }
    
    func searchVocab(keyword: String) -> [Vocab] {
      return []
    }
    
    func getListOfLowProficiencyVocab(inBook id: Int, upto numberOfVocabs: Int) -> [Vocab] {
      return []
    }
    
    func getListOfLowProficiencyVocab(inLesson id: Int, upto numberOfVocabs: Int) -> [Vocab] {
      return []
    }
    
    func getNeedReviewVocabs(upto numberOfVocabs: Int) -> [Vocab] {
      return[]
    }
    
    func getNeedReviewVocabs(inBook id: Int, upto numberOfVocabs: Int) -> [Vocab] {
      return []
    }
  }
}
