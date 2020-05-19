//
//  LessonDetailViewModelTests.swift
//  EasyKIIPTests
//
//  Created by Tuan on 2020/05/17.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import EasyKIIPKit
import SwiftDate

class LessonDetailViewModelTests: XCTestCase {
  
  var subscription: Disposable!
  
  override func setUp() {
    super.setUp()
    
    scheduler = TestScheduler(initialClock: 0)
  }
  
  override func tearDown() {
    scheduler.scheduleAt(1000) {
      self.subscription.dispose()
    }
    super.tearDown()
  }
  
  func test_init() {
    let (book, _, lesson, _) = makeSampleBook()
    let sut = makeSut(book: book, lesson: lesson)
    
  }
  
  
  // Classes
  private func makeSut(book: Book, lesson: Lesson) -> LessonDetailViewModel {
    let vocabRepository = VocabRepositoryStub(book: book, lesson: lesson)
    let sut = LessonDetailViewModel(book: book, lesson: lesson, vocabRepository: vocabRepository)
    return sut
  }
  
  // Sample book
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
    let lesson2 = Lesson(id: 2, name: "제1과 2", index: 2, translations: [.en: "Lesson 2", .vi: "Bải 2"], vocabs: [], readingParts: [])
    let lesson3 = Lesson(id: 3, name: "제1과 3", index: 3, translations: [.en: "Lesson 3", .vi: "Bải 3"], vocabs: [], readingParts: [])
    let lesson4 = Lesson(id: 4, name: "제1과 4", index: 4, translations: [.en: "Lesson 4", .vi: "Bải 4"], vocabs: [], readingParts: [])
    let lesson5 = Lesson(id: 5, name: "제1과 5", index: 5, translations: [.en: "Lesson 5", .vi: "Bải 5"], vocabs: [], readingParts: [])
    
    let lessons = [lesson1, lesson2, lesson3, lesson4, lesson5]
    
    let book = Book(id: 1, name: "한국어와 한국문화\n 기조", thumbURL: nil, lessons: lessons)
    return (book, lessons, lesson1, vocabs)
  }
  
  private class VocabRepositoryStub: VocabRepository {
    
    private let book: Book
    private let lesson: Lesson
    
    init(book: Book, lesson: Lesson) {
      self.book = book
      self.lesson = lesson
    }
    
    func getListOfBook() -> [Book] {
      return []
    }
    
    func getListOfLesson(inBook id: Int) -> Observable<[Lesson]> {
      return scheduler.createHotObservable([
        Recorded.next(500, book.lessons)
        ]).asObservable()
    }
    
    func getListOfVocabs(inBook bookID: Int, inLesson lessonID: Int) -> Observable<[Vocab]> {
      return Observable.empty()
    }
    
    func markVocabAsMastered(vocabID id: Int) {
      
    }
    
    func recordVocabPracticed(vocabID: Int, isCorrectAnswer: Bool) {
      
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
      return []
    }
    
    func getNeedReviewVocabs(inBook id: Int, upto numberOfVocabs: Int) -> [Vocab] {
      return []
    }
    
    func getListOfVocabs(in book: Book, lesson: Lesson) -> Observable<[Vocab]> {
      return Observable.empty()
    }
    
    func saveLessonPracticeHistory(inBook id: Int, lessonID: Int) {
      
    }
  }
}
