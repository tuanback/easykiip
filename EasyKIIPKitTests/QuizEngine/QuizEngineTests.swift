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
  func markAsMastered(for question: Question)
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
  func createANewQuestion(for: Question) -> Question
}

public enum Question: Equatable, Hashable {
  case newWord(NewWordQuestion)
  case practice(PracticeQuestion)
}

public struct NewWordQuestion: Equatable, Hashable {
  public let vocabID: Int
  public let word: String
  public let meaning: String
}

public struct PracticeQuestion: Equatable, Hashable {
  public let vocabID: Int
  public let question: String
  public let options: [String]
  public let answer: String
}

enum QuestionType {
  case newWord
  case practice
}

public class KIIPQuizEngine: QuizEngine {
  
  private let questionMaker: QuestionMaker
  private let vocabRepository: VocabRepository
  private let delegate: QuizEngineDelegate
  
  private var questions: [Question] = []
  
  private var mCurrentQuestion: Int = 0
  
  private let bookID: Int
  private let lessonID: Int
  private let vocabs: [Vocab]
  
  public init(bookID: Int,
              lessonID: Int,
              vocabs: [Vocab],
              questionMaker: QuestionMaker,
              vocabRepository: VocabRepository,
              delegate: QuizEngineDelegate) {
    self.bookID = bookID
    self.lessonID = lessonID
    self.vocabs = vocabs
    self.questionMaker = questionMaker
    self.vocabRepository = vocabRepository
    self.delegate = delegate
    self.questions = questionMaker.createQuestions()
  }
  
  public func start() {
    guard self.questions.count > 0 else {
      delegate.quizEngineDidCompleted()
      return
    }
    
    let question = self.questions[0]
    delegate.quizEngine(routeTo: question)
  }
  
  public func handleAnswer(for question: Question, answer: String? = nil) {
    
    switch question {
    case .practice(let q):
      guard let answer = answer else {
        fatalError("Can't answer practice question with nil answer")
      }
      if q.answer == answer {
        vocabRepository.recordVocabPracticed(vocabID: q.vocabID, isCorrectAnswer: true)
      }
      else {
        vocabRepository.recordVocabPracticed(vocabID: q.vocabID, isCorrectAnswer: false)
        let question = questionMaker.createANewQuestion(for: question)
        questions.append(question)
      }
    case .newWord(let q):
      vocabRepository.recordVocabPracticed(vocabID: q.vocabID, isCorrectAnswer: true)
    }
    
    guard mCurrentQuestion < questions.count - 1 else {
      delegate.quizEngineDidCompleted()
      vocabRepository.saveLessonPracticeHistory(inBook: bookID, lessonID: lessonID)
      return
    }
    
    mCurrentQuestion += 1
    let question = questions[mCurrentQuestion]
    delegate.quizEngine(routeTo: question)
  }
  
  public func markAsMastered(for question: Question) {
    let vocabID: Int
    switch question {
    case .newWord(let q):
      vocabID = q.vocabID
    case .practice(let q):
      vocabID = q.vocabID
    }
    vocabRepository.markVocabAsMastered(vocabID: vocabID)
  }
}

class QuizEngineTests: XCTestCase {
  
  func test_start_noQuestion_completeQuiz() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, _, delegate, vocabRepo, _) = makeSut(bookID: book.id, lessonID: lesson.id, vocabs: vocabs, questions: [])
    sut.start()
    
    XCTAssertTrue(delegate.completed)
    XCTAssertEqual(delegate.questions, [])
    XCTAssertFalse(vocabRepo.isSaveHistoryCalled)
  }
  
  func test_start_withOneQuestion_routeToFirstQuestion() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, _, delegate, _, questions) = makeSut(bookID: book.id, lessonID: lesson.id, vocabs: vocabs, questions: [(1, "Q1", "", .newWord)])
    sut.start()
    
    let expectedQuestion = questions[0]
    XCTAssertEqual(delegate.questions, [expectedQuestion])
  }
  
  func test_start_withOneNewWordQuestion_answerQuestion_completeQuiz() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, _, delegate, vocabRepo, questions) = makeSut(bookID: book.id, lessonID: lesson.id, vocabs: vocabs, questions: [(1, "Q1", "", .newWord)])
    sut.start()
    
    let question = questions[0]
    sut.handleAnswer(for: question)
    
    XCTAssertTrue(delegate.completed)
    XCTAssertTrue(vocabRepo.isSaveHistoryCalled)
  }
  
  func test_startWithTwoQuestions_answer1Question_routeToSecondQuestion() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, _, delegate, _, questions) = makeSut(bookID: book.id, lessonID: lesson.id, vocabs: vocabs, questions: [(1, "Q1", "", .newWord),
                                                                                                                     (2, "Q2", "", .newWord)])
    sut.start()
    
    let question1 = questions[0]
    let question2 = questions[1]
    
    sut.handleAnswer(for: question1)
    
    XCTAssertFalse(delegate.completed)
    XCTAssertEqual(delegate.questions, [question1, question2])
  }
  
  func test_startWithTwoQuestions_answer2Questions_completeQuiz() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, _, delegate, vocabRepo, questions) = makeSut(bookID: book.id, lessonID: lesson.id, vocabs: vocabs, questions: [(1, "Q1", "", .newWord),
                                                                                                                             (2, "Q2", "", .newWord)])
    sut.start()
    
    let question1 = questions[0]
    let question2 = questions[1]
    
    sut.handleAnswer(for: question1)
    sut.handleAnswer(for: question2)
    
    XCTAssertTrue(delegate.completed)
    XCTAssertEqual(delegate.questions, [question1, question2])
    XCTAssertTrue(vocabRepo.isSaveHistoryCalled)
  }
  
  func test_start_withTwoPracticeQuestions_answer1Question_correct_routeToSecondQuestion() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, _, delegate, _, questions) = makeSut(bookID: book.id, lessonID: lesson.id, vocabs: vocabs, questions: [(1, "Q1", "A1", .practice),
                                                                                                                     (2, "Q2", "A2", .practice)])
    sut.start()
    
    let question1 = questions[0]
    let question2 = questions[1]
    
    sut.handleAnswer(for: question1, answer: "A1")
    
    XCTAssertFalse(delegate.completed)
    XCTAssertEqual(delegate.questions, [question1, question2])
  }
  
  func test_start_withOnePracticeQuestions_answer1Question_wrong_routeToSecondQuestion() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, questionMaker, delegate, _, questions) = makeSut(bookID: book.id, lessonID: lesson.id, vocabs: vocabs, questions: [(1, "Q1", "A1", .practice)])
    sut.start()
    
    let question1 = questions[0]
    
    sut.handleAnswer(for: question1, answer: "")
    
    let question2 = questionMaker.newCreatedQuestionDic[question1]
    
    XCTAssertNotNil(question2)
    XCTAssertFalse(delegate.completed)
    if let q2 = question2 {
      XCTAssertEqual(delegate.questions, [question1, q2])
    }
  }
  
  func test_start_withTwoPracticeQuestions_answer1Question_wrong_routeToThirdQuestion() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, questionMaker, delegate, _, questions) = makeSut(bookID: book.id, lessonID: lesson.id, vocabs: vocabs, questions: [(1, "Q1", "A1", .practice),
                                                                                                                                 (2, "Q2", "A2", .practice)])
    sut.start()
    
    let question1 = questions[0]
    let question2 = questions[1]
    
    sut.handleAnswer(for: question1, answer: "")
    sut.handleAnswer(for: question2, answer: "A2")
    
    let question3 = questionMaker.newCreatedQuestionDic[question1]
    
    XCTAssertNotNil(question3)
    XCTAssertFalse(delegate.completed)
    if let q3 = question3 {
      XCTAssertEqual(delegate.questions, [question1, question2, q3])
    }
  }
  
  func test_start_withTwoPracticeQuestions_answer2Questions_wrong_routeToThirdFourthQuestion() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, questionMaker, delegate, _, questions) = makeSut(bookID: book.id, lessonID: lesson.id, vocabs: vocabs, questions: [(1, "Q1", "A1", .practice),
                                                                                                                                 (2, "Q2", "A2", .practice)])
    sut.start()
    
    let question1 = questions[0]
    let question2 = questions[1]
    
    sut.handleAnswer(for: question1, answer: "")
    sut.handleAnswer(for: question2, answer: "")
    
    let question3 = questionMaker.newCreatedQuestionDic[question1]
    let question4 = questionMaker.newCreatedQuestionDic[question2]
    
    XCTAssertNotNil(question3)
    XCTAssertNotNil(question4)
    
    sut.handleAnswer(for: question3!, answer: "A1")
    
    XCTAssertFalse(delegate.completed)
    if let q3 = question3, let q4 = question4 {
      XCTAssertEqual(delegate.questions, [question1, question2, q3, q4])
    }
  }
  
  func test_start_withTwoPracticeQuestions_answer2Questions_wrong_answerAgain_correct_completeQuiz() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, questionMaker, delegate, vocabRepo, questions) = makeSut(bookID: book.id, lessonID: lesson.id, vocabs: vocabs, questions: [(1, "Q1", "A1", .practice),
                                                                                                                                         (2, "Q2", "A2", .practice)])
    sut.start()
    
    let question1 = questions[0]
    let question2 = questions[1]
    
    sut.handleAnswer(for: question1, answer: "")
    sut.handleAnswer(for: question2, answer: "")
    
    let question3 = questionMaker.newCreatedQuestionDic[question1]
    let question4 = questionMaker.newCreatedQuestionDic[question2]
    
    XCTAssertNotNil(question3)
    XCTAssertNotNil(question4)
    
    sut.handleAnswer(for: question3!, answer: "A1")
    sut.handleAnswer(for: question4!, answer: "A2")
    
    XCTAssertTrue(delegate.completed)
    if let q3 = question3, let q4 = question4 {
      XCTAssertEqual(delegate.questions, [question1, question2, q3, q4])
    }
    XCTAssertTrue(vocabRepo.isSaveHistoryCalled)
  }
  
  func test_start_withOneNewWordQuestion_learnt_recordPracticeHistory() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, _, _, vocabRepo, questions) = makeSut(bookID: book.id,
                                                                       lessonID: lesson.id,
                                                                       vocabs: vocabs,
                                                                       questions: [(1, "Q1", "A1", .newWord)])
    sut.start()
    
    sut.handleAnswer(for: questions[0])
    
    XCTAssertTrue(vocabRepo.recordVocabPracticedSet[1]!)
  }
  
  func test_start_withTwoNewWordQuestion_learnt_recordPracticeHistory() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, _, _, vocabRepo, questions) = makeSut(bookID: book.id,
                                                                       lessonID: lesson.id,
                                                                       vocabs: vocabs,
                                                                       questions: [(1, "Q1", "A1", .newWord),
                                                                                   (2, "Q2", "A2", .newWord)])
    sut.start()
    
    sut.handleAnswer(for: questions[0])
    sut.handleAnswer(for: questions[1])
    
    XCTAssertTrue(vocabRepo.recordVocabPracticedSet[1]!)
    XCTAssertTrue(vocabRepo.recordVocabPracticedSet[2]!)
  }
  
  func test_start_withOnePracticeQuestion_answer_correct_recordPracticeHistory() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, _, _, vocabRepo, questions) = makeSut(bookID: book.id,
                                                                       lessonID: lesson.id,
                                                                       vocabs: vocabs,
                                                                       questions: [(1, "Q1", "A1", .practice)])
    sut.start()
    
    sut.handleAnswer(for: questions[0], answer: "A1")
    
    XCTAssertTrue(vocabRepo.recordVocabPracticedSet[1]!)
  }
  
  func test_start_withOnePracticeQuestion_answer_wrong_recordPracticeHistory() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, _, _, vocabRepo, questions) = makeSut(bookID: book.id,
                                                                       lessonID: lesson.id,
                                                                       vocabs: vocabs,
                                                                       questions: [(1, "Q1", "A1", .practice)])
    sut.start()
    
    sut.handleAnswer(for: questions[0], answer: "")
    
    XCTAssertFalse(vocabRepo.recordVocabPracticedSet[1]!)
  }
  
  func test_start_withOneNewWordQuestion_markAsMastered_funcIsCalled() {
    let (book, _, lesson, vocabs) = makeSampleBook()
    let (sut, _, _, vocabRepo, questions) = makeSut(bookID: book.id,
                                                                       lessonID: lesson.id,
                                                                       vocabs: vocabs,
                                                                       questions: [(1, "Q1", "A1", .newWord)])
    sut.start()
    
    sut.markAsMastered(for: questions[0])
    
    XCTAssertTrue(vocabRepo.markAsMasteredArray.contains(1))
  }
  
  // Helpers
  private func makeSut(bookID: Int, lessonID: Int, vocabs: [Vocab], questions: [(Int, String, String, QuestionType)]) -> (KIIPQuizEngine, QuestionMakerStub, QuizEngineDelegateSpy, VocabRepositoryStub, [Question]) {
    let vocabRepository = VocabRepositoryStub()
    let questionMaker = QuestionMakerStub(questions: questions)
    let questions = questionMaker.questions
    let delegate = QuizEngineDelegateSpy()
    let sut = KIIPQuizEngine(bookID: bookID,
                             lessonID: lessonID,
                             vocabs: vocabs,
                             questionMaker: questionMaker,
                             vocabRepository: vocabRepository,
                             delegate: delegate)
    return (sut, questionMaker, delegate, vocabRepository, questions)
  }
  
  private func makeSampleBook() -> (Book, [Lesson], Lesson, [Vocab]) {
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
    
    let readingPart = ReadingPart(scriptName: "Script", script: "안녕하세요~", scriptNameTranslation: [.en: "Script", .vi: "Script"], scriptTranslation: [.en: "Hello", .vi: "Xin chào"])
    
    let vocabs = [vocab1, vocab2, vocab3, vocab4, vocab5, vocab6, vocab7, vocab8, vocab9, vocab10, vocab11]
    
    let lesson1 = Lesson(id: 1, name: "제1과 1", index: 1, translations: [.en: "Lesson 1", .vi: "Bải 1"], vocabs: vocabs, readingParts: [readingPart])
    let lesson2 = Lesson(id: 2, name: "제1과 2", index: 2, translations: [.en: "Lesson 2", .vi: "Bải 2"], vocabs: vocabs, readingParts: [])
    let lesson3 = Lesson(id: 3, name: "제1과 3", index: 3, translations: [.en: "Lesson 3", .vi: "Bải 3"], vocabs: [], readingParts: [readingPart])
    let lesson4 = Lesson(id: 4, name: "제1과 4", index: 4, translations: [.en: "Lesson 4", .vi: "Bải 4"], vocabs: [], readingParts: [])
    let lesson5 = Lesson(id: 5, name: "제1과 5", index: 5, translations: [.en: "Lesson 5", .vi: "Bải 5"], vocabs: [], readingParts: [])
    
    let lessons = [lesson1, lesson2, lesson3, lesson4, lesson5]
    
    let book = Book(id: 1, name: "한국어와 한국문화\n 기조", thumbURL: nil, lessons: lessons)
    return (book, lessons, lesson1, vocabs)
  }
  
  class QuestionMakerStub: QuestionMaker {
    
    private(set) var questions: [Question]
    private(set) var newCreatedQuestionDic: [Question: Question] = [:]
    
    init(questions: [(Int, String, String, QuestionType)]) {
      self.questions = questions.map {
        switch $0.3 {
        case .newWord:
          return Question.newWord(NewWordQuestion(vocabID: $0.0, word: $0.1, meaning: $0.2))
        case .practice:
          return Question.practice(PracticeQuestion(vocabID: $0.0, question: $0.1, options: [], answer: $0.2))
        }
      }
    }
    
    func createQuestions() -> [Question] {
      return self.questions
    }
    
    func createANewQuestion(for question: Question) -> Question {
      newCreatedQuestionDic[question] = question
      return question
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
    
    var isSaveHistoryCalled = false
    var recordVocabPracticedSet: [Int: Bool] = [:]
    var markAsMasteredArray: [Int] = []
    
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
      markAsMasteredArray.append(id)
    }
    
    func recordVocabPracticed(vocabID: Int, isCorrectAnswer: Bool) {
      recordVocabPracticedSet[vocabID] = isCorrectAnswer
    }
    
    func saveLessonPracticeHistory(inBook id: Int, lessonID: Int) {
      isSaveHistoryCalled = true
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
