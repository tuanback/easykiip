//
//  KIIPQuizEngine.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/06/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public enum QuizEngineError: Error {
  case noQuestion
}

public class KIIPQuizEngine: QuizEngine {
  public weak var delegate: QuizEngineDelegate?
  
  private let questionMaker: QuestionMaker
  private let vocabRepository: VocabRepository
  
  private var questions: [Question] = []
  
  private var mCurrentQuestion: Int = 0
  
  private let bookID: Int
  private let lessonID: Int
  private let vocabs: [Vocab]
  private var numberOfHeart: Int?
  private var maxHeart: Int?
  
  public init(bookID: Int,
              lessonID: Int,
              vocabs: [Vocab],
              numberOfHeart: Int?,
              questionMaker: QuestionMaker,
              vocabRepository: VocabRepository) {
    self.bookID = bookID
    self.lessonID = lessonID
    self.vocabs = vocabs
    self.maxHeart = numberOfHeart
    self.numberOfHeart = numberOfHeart
    self.questionMaker = questionMaker
    self.vocabRepository = vocabRepository
    self.questions = questionMaker.createQuestions()
  }
  
  public func start() throws {
    guard self.questions.count > 0 else {
      throw QuizEngineError.noQuestion
    }
    
    let question = self.questions[0]
    delegate?.quizEngine(routeTo: question)
    if let heart = numberOfHeart, let maxHeart = self.maxHeart {
      delegate?.quizEngine(numberOfHeart: heart, totalHeart: maxHeart)
    }
  }
  
  public func handleAnswer(for question: Question, answer: String? = nil) {
    
    switch question {
    case .practice(let q):
      guard let answer = answer else {
        fatalError("Can't answer practice question with nil answer")
      }
      if q.answer == answer {
        vocabRepository.recordVocabPracticed(vocabID: q.vocabID, isCorrectAnswer: true)
        delegate?.quizEngine(correctAnswerFor: question, answer: answer)
      }
      else {
        vocabRepository.recordVocabPracticed(vocabID: q.vocabID, isCorrectAnswer: false)
        let question = questionMaker.createANewQuestion(for: question)
        if !questions.contains(question) {
          questions.append(question)
        }
        if let heart = self.numberOfHeart, let maxHeart = self.maxHeart {
          numberOfHeart = heart - 1
          delegate?.quizEngine(numberOfHeart: heart - 1, totalHeart: maxHeart)
        }
        delegate?.quizEngine(wrongAnswerFor: question, answer: answer)
        // If user answer is wrong => Let user to select again, don't route to next question
        return
      }
    case .newWord(let q):
      vocabRepository.recordVocabPracticed(vocabID: q.vocabID, isCorrectAnswer: true)
    }
    
    routeToNextQuestion()
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
    
    // NOTE: Vocab is marked as mastered, no need to practice more
    questions.removeAll { (question) -> Bool in
      switch question {
      case .newWord(let q):
        return q.vocabID == vocabID
      case .practice(let q):
        return q.vocabID == vocabID
      }
    }
    
    routeToNextQuestion()
  }
  
  private func routeToNextQuestion() {
    guard mCurrentQuestion < questions.count - 1 else {
      delegate?.quizEngineDidCompleted()
      vocabRepository.saveLessonPracticeHistory(inBook: bookID, lessonID: lessonID)
      return
    }
    
    mCurrentQuestion += 1
    let question = questions[mCurrentQuestion]
    delegate?.quizEngine(routeTo: question)
  }
  
  public func refillHeart() {
    numberOfHeart = maxHeart
    if let heart = numberOfHeart, let maxHeart = self.maxHeart {
      delegate?.quizEngine(numberOfHeart: heart, totalHeart: maxHeart)
    }
  }
}
