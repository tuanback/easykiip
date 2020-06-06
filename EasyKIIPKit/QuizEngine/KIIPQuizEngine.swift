//
//  KIIPQuizEngine.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/06/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class KIIPQuizEngine: QuizEngine {
  
  private let questionMaker: QuestionMaker
  private let vocabRepository: VocabRepository
  private let delegate: QuizEngineDelegate
  
  private var questions: [Question] = []
  
  private var mCurrentQuestion: Int = 0
  
  private let bookID: Int
  private let lessonID: Int
  private let vocabs: [Vocab]
  private var numberOfHeart: Int?
  
  public init(bookID: Int,
              lessonID: Int,
              vocabs: [Vocab],
              numberOfHeart: Int?,
              questionMaker: QuestionMaker,
              vocabRepository: VocabRepository,
              delegate: QuizEngineDelegate) {
    self.bookID = bookID
    self.lessonID = lessonID
    self.vocabs = vocabs
    self.numberOfHeart = numberOfHeart
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
    if let heart = numberOfHeart {
      delegate.quizEngine(numberOfHeart: heart)
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
      }
      else {
        vocabRepository.recordVocabPracticed(vocabID: q.vocabID, isCorrectAnswer: false)
        let question = questionMaker.createANewQuestion(for: question)
        questions.append(question)
        if let heart = self.numberOfHeart {
          numberOfHeart = heart - 1
          delegate.quizEngine(numberOfHeart: heart - 1)
        }
        // If user answer is wrong => Let user to select again, don't route to next question
        return
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
