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
  func handleAnswer(for question: Question, answer: String?)
}

public protocol QuizEngineDelegate {
  func quizEngine(routeTo question: Question)
  func quizEngineDidCompleted()
}

enum QuizEngineError: LocalizedError {
  case noQuestion
}

public protocol QuestionMaker {
  func createQuestions() -> [Question]
}

public enum QuestionType {
  case newWord
  case practice
}

public struct Question: Equatable {
  public let question: String
  public let questionType: QuestionType
  public let options: [String]
  public let answer: String
}

public class KIIPQuizEngine: QuizEngine {
  
  private let questionMaker: QuestionMaker
  private let vocabRepository: VocabRepository
  private let delegate: QuizEngineDelegate
  
  private var questions: [Question] = []
  
  private var mCurrentQuestion: Int = 0
  
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
    delegate.quizEngine(routeTo: question)
  }
  
  public func handleAnswer(for question: Question, answer: String? = nil) {
    guard mCurrentQuestion < questions.count - 1 else {
      delegate.quizEngineDidCompleted()
      return
    }
    
    mCurrentQuestion += 1
    let question = questions[mCurrentQuestion]
    delegate.quizEngine(routeTo: question)
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
    let questionMaker = QuestionMakerStub(questions: [("Q1", .newWord)])
    let delegate = QuizEngineDelegateSpy()
    let sut = KIIPQuizEngine(questionMaker: questionMaker,
                             vocabRepository: vocabRepository,
                             delegate: delegate)
    try sut.start()
    
    XCTAssertEqual(delegate.questions, [Question(question: "Q1",
                                                 questionType: .newWord,
                                                 options: [], answer: "")])
  }
  
  func test_start_withOneNewWordQuestion_answerQuestion_completeQuiz() throws {
    let vocabRepository = VocabRepositoryStub()
    let questionMaker = QuestionMakerStub(questions: [("Q1", .newWord)])
    let question = Question(question: "Q1", questionType: .newWord, options: [], answer: "")
    let delegate = QuizEngineDelegateSpy()
    let sut = KIIPQuizEngine(questionMaker: questionMaker,
                             vocabRepository: vocabRepository,
                             delegate: delegate)
    try sut.start()
    
    sut.handleAnswer(for: question)
    
    XCTAssertTrue(delegate.completed)
  }
  
  func test_startWithTwoQuestions_answer1Question_routeToSecondQuestion() throws {
    
    let vocabRepository = VocabRepositoryStub()
    let questionMaker = QuestionMakerStub(questions: [("Q1", .newWord),
                                                      ("Q2", .newWord)])
    let question1 = Question(question: "Q1", questionType: .newWord, options: [], answer: "")
    let question2 = Question(question: "Q2", questionType: .newWord, options: [], answer: "")
    let delegate = QuizEngineDelegateSpy()
    let sut = KIIPQuizEngine(questionMaker: questionMaker,
                             vocabRepository: vocabRepository,
                             delegate: delegate)
    try sut.start()
    
    sut.handleAnswer(for: question1)
    
    XCTAssertFalse(delegate.completed)
    XCTAssertEqual(delegate.questions, [question1, question2])
  }
  
  
  // Helpers
  
  class QuestionMakerStub: QuestionMaker {
    
    private(set) var questions: [Question]
    
    init(questions: [(String, QuestionType)]) {
      self.questions = questions.map { Question(question: $0.0,
                                                questionType: $0.1,
                                                options: [], answer: "") }
    }
    
    func createQuestions() -> [Question] {
      return self.questions
    }
  }

  class QuizEngineDelegateSpy: QuizEngineDelegate {
    private(set) var questions: [Question] = []
    private(set) var completed = false
    
    init() {
      
    }
    
    func quizEngine(routeTo question: Question) {
      self.questions.append(question)
    }
    
    func quizEngineDidCompleted() {
      completed = true
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
