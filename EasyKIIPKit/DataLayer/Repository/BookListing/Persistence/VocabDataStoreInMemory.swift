//
//  VocabDataStoreInMemory.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

class VocabDataStoreInMemory: VocabDataStore {
  
  private var books: [Book] = []

  init() {
    books = initInMemoryDataStore()
  }
  
  private func initInMemoryDataStore() -> [Book] {
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
    
    let readingPart = ReadingPart(id: 0, script: "안녕하세요~", translations: [.en: "Hello", .vi: "Xin chào"])
    
    let lesson1 = Lesson(id: 1, name: "제1과 1", translations: [.en: "Lesson 1", .vi: "Bải 1"], vocabs: [vocab1, vocab2, vocab3, vocab4, vocab5, vocab6, vocab7, vocab8, vocab9, vocab10, vocab11], readingParts: [readingPart])
    let lesson2 = Lesson(id: 2, name: "제1과 2", translations: [.en: "Lesson 2", .vi: "Bải 2"], vocabs: [], readingParts: [])
    let lesson3 = Lesson(id: 3, name: "제1과 3", translations: [.en: "Lesson 3", .vi: "Bải 3"], vocabs: [], readingParts: [])
    let lesson4 = Lesson(id: 4, name: "제1과 4", translations: [.en: "Lesson 4", .vi: "Bải 4"], vocabs: [], readingParts: [])
    let lesson5 = Lesson(id: 5, name: "제1과 5", translations: [.en: "Lesson 5", .vi: "Bải 5"], vocabs: [], readingParts: [])
    
    let book1 = Book(id: 0, name: "조급 1", thumbName: nil, lessons: [lesson1, lesson2, lesson3, lesson4, lesson5])
    let book2 = Book(id: 0, name: "조급 2", thumbName: nil, lessons: [])
    let book3 = Book(id: 0, name: "조급 3", thumbName: nil, lessons: [])
    
    return [book1, book2, book3]
  }
  
  func getListOfBook() -> [Book] {
    return books
  }
  
  func getListOfLesson(in book: Book) -> [Lesson] {
    return book.lessons
  }
  
  func getListOfVocabs(in lesson: Lesson) -> [Vocab] {
    return lesson.vocabs
  }
  
  func markVocabAsMastered(_ vocab: Vocab) {
    let vocabs = books.flatMap { $0.lessons.flatMap { $0.vocabs } }
    if let v = vocabs.first(where: { $0.id == vocab.id }) {
      v.markAsIsMastered()
    }
  }
  
  func recordVocabPracticed(vocab: Vocab, isCorrectAnswer: Bool) {
    let vocabs = books.flatMap { $0.lessons.flatMap { $0.vocabs } }
    if let v = vocabs.first(where: { $0.id == vocab.id }) {
      isCorrectAnswer ? v.increaseNumberOfCorrectAnswerByOne() : v.increaseNumberOfWrongAnswerByOne()
    }
  }
  
  func getVocab(by id: UInt) -> Vocab? {
    let vocabs = books.flatMap { $0.lessons.flatMap { $0.vocabs } }
    if let v = vocabs.first(where: { $0.id == id }) {
      return v
    }
    return nil
  }
  
  func searchVocab(keyword: String) -> [Vocab]  {
    let vocabs = books.flatMap { $0.lessons.flatMap { $0.vocabs } }
    
    let result = vocabs.filter { (vocab) -> Bool in
      if vocab.word.lowercased().contains(keyword.lowercased()) {
        return true
      }
      
      for (_, value) in vocab.translations {
        if value.lowercased().contains(keyword.lowercased()) {
          return true
        }
      }
      return false
    }
    return result
  }
  
  func syncPracticeHistory(vocabID: UInt, testTaken: UInt, correctAnswer: UInt, firstLearnDate: Date, lastTimeTest: Date) {
    let vocabs = books.flatMap { $0.lessons.flatMap { $0.vocabs } }
    if let v = vocabs.first(where: { $0.id == vocabID }) {
      try? v.setTestTakenData(numberOfTestTaken: testTaken, numberOfCorrectAnswer: correctAnswer, firstLearnDate: firstLearnDate, lastTimeTest: lastTimeTest)
    }
  }
  
}
