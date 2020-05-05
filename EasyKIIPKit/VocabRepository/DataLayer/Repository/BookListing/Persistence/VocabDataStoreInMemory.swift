//
//  VocabDataStoreInMemory.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class VocabDataStoreInMemory: VocabDataStore {
  
  private var books: [Book] = []

  public init() {
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
    
    let lesson1 = Lesson(id: 1, name: "제1과 1", index: 1, translations: [.en: "Lesson 1", .vi: "Bải 1"], vocabs: [vocab1, vocab2, vocab3, vocab4, vocab5, vocab6, vocab7, vocab8, vocab9, vocab10, vocab11], readingParts: [readingPart])
    let lesson2 = Lesson(id: 2, name: "제1과 2", index: 2, translations: [.en: "Lesson 2", .vi: "Bải 2"], vocabs: [], readingParts: [])
    let lesson3 = Lesson(id: 3, name: "제1과 3", index: 3, translations: [.en: "Lesson 3", .vi: "Bải 3"], vocabs: [], readingParts: [])
    let lesson4 = Lesson(id: 4, name: "제1과 4", index: 4, translations: [.en: "Lesson 4", .vi: "Bải 4"], vocabs: [], readingParts: [])
    let lesson5 = Lesson(id: 5, name: "제1과 5", index: 5, translations: [.en: "Lesson 5", .vi: "Bải 5"], vocabs: [], readingParts: [])
    
    let thumb1 = Bundle.init(for: type(of: self)).url(forResource: "book_0", withExtension: ".jpg")
    let thumb2 = Bundle.init(for: type(of: self)).url(forResource: "book_1", withExtension: ".jpg")
    let thumb3 = Bundle.init(for: type(of: self)).url(forResource: "book_2", withExtension: ".jpg")
    let thumb4 = Bundle.init(for: type(of: self)).url(forResource: "book_3", withExtension: ".jpg")
    let thumb5 = Bundle.init(for: type(of: self)).url(forResource: "book_4", withExtension: ".jpg")
    let thumb6 = Bundle.init(for: type(of: self)).url(forResource: "book_5", withExtension: ".jpg")
    let thumb7 = Bundle.init(for: type(of: self)).url(forResource: "book_6", withExtension: ".jpg")
    
    let book1 = Book(id: 1, name: "한국어와 한국문화\n 기조", thumbURL: thumb1, lessons: [lesson1, lesson2, lesson3, lesson4, lesson5])
    let book2 = Book(id: 2, name: "한국어와 한국문화\n조급 1", thumbURL: thumb2, lessons: [])
    let book3 = Book(id: 3, name: "한국어와 한국문화\n조급 2", thumbURL: thumb3, lessons: [])
    let book4 = Book(id: 4, name: "한국어와 한국문화\n중급 1", thumbURL: thumb4, lessons: [])
    let book5 = Book(id: 5, name: "한국어와 한국문화\n중급 2", thumbURL: thumb5, lessons: [])
    let book6 = Book(id: 6, name: "한국사회 이해\n기본", thumbURL: thumb6, lessons: [])
    let book7 = Book(id: 7, name: "한국사회 이해\n심화", thumbURL: thumb7, lessons: [])
    
    return [book1, book2, book3, book4, book5, book6, book7]
  }
  
  public func getListOfBook() -> [Book] {
    return books
  }
  
  public func getListOfLesson(in book: Book) -> [Lesson] {
    return book.lessons
  }
  
  public func getListOfVocabs(in lesson: Lesson) -> [Vocab] {
    return lesson.vocabs
  }
  
  public func markVocabAsMastered(_ vocab: Vocab) {
    let vocabs = books.flatMap { $0.lessons.flatMap { $0.vocabs } }
    if let v = vocabs.first(where: { $0.id == vocab.id }) {
      v.markAsIsMastered()
    }
  }
  
  public func recordVocabPracticed(vocab: Vocab, isCorrectAnswer: Bool) {
    let vocabs = books.flatMap { $0.lessons.flatMap { $0.vocabs } }
    if let v = vocabs.first(where: { $0.id == vocab.id }) {
      isCorrectAnswer ? v.increaseNumberOfCorrectAnswerByOne() : v.increaseNumberOfWrongAnswerByOne()
    }
  }
  
  public func getVocab(by id: UInt) -> Vocab? {
    let vocabs = books.flatMap { $0.lessons.flatMap { $0.vocabs } }
    if let v = vocabs.first(where: { $0.id == id }) {
      return v
    }
    return nil
  }
  
  public func searchVocab(keyword: String) -> [Vocab]  {
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
  
  public func syncLessonProficiency(lessonID: UInt, proficiency: UInt8, lastTimeSynced: Double) {
    guard let lesson = books.flatMap({ $0.lessons }).first(where: { $0.id == lessonID }) else { return }
    lesson.setProficiency(proficiency)
  }
  
  public func syncPracticeHistory(vocabID: UInt,
                                  isMastered: Bool,
                                  testTaken: UInt,
                                  correctAnswer: UInt,
                                  firstLearnDate: Date,
                                  lastTimeTest: Date) {
    let vocabs = books.flatMap { $0.lessons.flatMap { $0.vocabs } }
    if let v = vocabs.first(where: { $0.id == vocabID }) {
      try? v.setTestTakenData(isMastered: isMastered,
                              numberOfTestTaken: testTaken,
                              numberOfCorrectAnswer: correctAnswer,
                              firstLearnDate: firstLearnDate,
                              lastTimeTest: lastTimeTest)
    }
  }
  
}
