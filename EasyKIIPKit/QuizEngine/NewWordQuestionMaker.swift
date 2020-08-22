//
//  NewWordQuestionMaker.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/06/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class NewWordQuestionMaker: QuestionMaker {
  
  enum PracticeQuestionType {
    case wordIsQuestion
    case meaningIsQuestion
  }
  
  private let numberOfOptions = 3
  private let createQuestionVocabs: [Vocab]
  private let randomVocabs: [Vocab]
  private let languageCode: LanguageCode
  
  public init(createQuestionVocabs: [Vocab],
              randomVocabs: [Vocab],
              languageCode: LanguageCode) {
    self.createQuestionVocabs = createQuestionVocabs
    self.randomVocabs = randomVocabs
    self.languageCode = languageCode
  }
  
  public func createQuestions() -> [Question] {
    
    var questions: [Question] = []
    var orderQuestions: [Question] = []
    var shuffleQuestions: [Question] = []
    let allVocabs = createQuestionVocabs + randomVocabs
    
    for vocab in createQuestionVocabs {
      guard !vocab.practiceHistory.isMastered else { continue }
      let differentVocabs = getDifferentVocabs(numberOfDiffrentVocab: numberOfOptions - 1,
                                               vocab: vocab, allVocabs: allVocabs)
      let (orderQs, shuffleQs) = createQuestions(for: vocab, otherVocabs: differentVocabs)
      orderQuestions.append(contentsOf: orderQs)
      shuffleQuestions.append(contentsOf: shuffleQs)
    }
    
    questions = orderQuestions + shuffleQuestions.shuffled()
    
    let notLearnedQuestion = createQuestionVocabs.filter({ !$0.practiceHistory.isLearned && !$0.practiceHistory.isMastered })
    
    if notLearnedQuestion.count == 0 {
      return questions.shuffled()
    }
    
    return questions
  }
  
  public func createANewQuestion(for question: Question) -> Question {
    switch question {
    case .newWord(_):
      return question
    case .practice(let q):
      if let vocab = createQuestionVocabs.first(where: { $0.id == q.vocabID }) {
        let allVocabs = createQuestionVocabs + randomVocabs
        let differentVocabs = getDifferentVocabs(numberOfDiffrentVocab: numberOfOptions - 1,
                                                 vocab: vocab, allVocabs: allVocabs)
        if let newQuestion = createWordIsQuestion(vocab: vocab, otherVocabs: differentVocabs) {
          if newQuestion != question {
            return newQuestion
          }
        }
        
        if let newQuestion = createMeaningIsQuestion(vocab: vocab, otherVocabs: differentVocabs) {
          if newQuestion != question {
            return newQuestion
          }
        }
      }
    }
    
    return question
  }
  
  private func getDifferentVocabs(numberOfDiffrentVocab: Int,
                                  vocab: Vocab,
                                  allVocabs: [Vocab]) -> [Vocab] {
    
    var differentVocabs = allVocabs.filter { $0.id != vocab.id }
    
    guard differentVocabs.count > numberOfDiffrentVocab else {
      return differentVocabs
    }
    
    var vocabs: [Vocab] = []
    
    while vocabs.count < numberOfDiffrentVocab {
      let index = Int.random(in: 0..<differentVocabs.count)
      let vocab = differentVocabs[index]
      differentVocabs.remove(at: index)
      vocabs.append(vocab)
    }
    
    return vocabs
  }
  
  private func createQuestions(for vocab: Vocab, otherVocabs: [Vocab]) -> ([Question], [Question]) {
    var questions: [Question] = []
    
    if !vocab.practiceHistory.isLearned,
      let question = createNewWordQuestion(vocab: vocab) {
      questions.append(question)
    }
    
    var practiceQuestions: [Question] = []
    
    if let q = createPracticeQuestion(mode: .wordIsQuestion, vocab: vocab, otherVocabs: otherVocabs) {
      practiceQuestions.append(q)
    }
    
    if let q = createPracticeQuestion(mode: .meaningIsQuestion, vocab: vocab, otherVocabs: otherVocabs) {
      practiceQuestions.append(q)
    }
    
    practiceQuestions.shuffle()
    
    questions.append(contentsOf: practiceQuestions)
    
    var orderQuestions: [Question] = []
    var shuffleQuestions: [Question] = []
    
    // New word question included
    if questions.count == 3 {
      orderQuestions = Array(questions.prefix(2))
      shuffleQuestions = [questions[2]]
    }
    else {
      // Only include practice question
      shuffleQuestions = questions
    }
    
    return (orderQuestions, shuffleQuestions)
  }
  
  private func createNewWordQuestion(vocab: Vocab) -> Question? {
    if let translation = vocab.translations[languageCode] {
      let question = Question.newWord(NewWordQuestion(vocabID: vocab.id,
                                                      word: vocab.word,
                                                      meaning: translation))
      return question
    }
    return nil
  }
  
  private func createPracticeQuestion(mode: PracticeQuestionType,
                                     vocab: Vocab,
                                     otherVocabs: [Vocab]) -> Question? {
    switch mode {
    case .wordIsQuestion:
      return createWordIsQuestion(vocab: vocab, otherVocabs: otherVocabs)
    case .meaningIsQuestion:
      return createMeaningIsQuestion(vocab: vocab, otherVocabs: otherVocabs)
    }
  }
  
  private func createWordIsQuestion(vocab: Vocab,
                                    otherVocabs: [Vocab]) -> Question? {
    var options: [String] = []
    var answer: String = ""
    
    guard let trans = vocab.translations[languageCode] else {
      return nil
    }
      
    options.append(trans)
    answer = trans
    
    for v in otherVocabs {
      if let trans = v.translations[languageCode] {
        options.append(trans)
      }
    }
    
    guard options.count >= 2 else { return nil}
    options.shuffle()
    
    let practiceQuestion = PracticeQuestion(vocabID: vocab.id,
                                            question: vocab.word,
                                            isQuestionKorean: true,
                                            options: options,
                                            answer: answer)
    let question = Question.practice(practiceQuestion)
    return question
  }
  
  private func createMeaningIsQuestion(vocab: Vocab,
                                       otherVocabs: [Vocab]) -> Question? {
    var options: [String] = []
    var questionStr: String = ""
    
    guard let trans = vocab.translations[languageCode] else {
      return nil
    }
    
    options.append(vocab.word)
    questionStr = trans
    
    for v in otherVocabs {
      options.append(v.word)
    }
    
    guard options.count >= 2 else { return nil}
    options.shuffle()
    
    let practiceQuestion = PracticeQuestion(vocabID: vocab.id,
                                            question: questionStr,
                                            isQuestionKorean: false,
                                            options: options,
                                            answer: vocab.word)
    let question = Question.practice(practiceQuestion)
    return question
  }
  
}
