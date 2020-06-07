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
@testable import Easy_KIIP

extension LearnVocabItemViewModel: Equatable {
  public static func == (lhs: LearnVocabItemViewModel, rhs: LearnVocabItemViewModel) -> Bool {
    if lhs.index == rhs.index && lhs.proficiency == rhs.proficiency && lhs.vocabs.count == rhs.vocabs.count {
      return true
    }
    return false
  }
}

class LessonDetailViewModelTests: XCTestCase {
  
  var subscription: Disposable!
  
  private var book: Book!
  private var lessons: [Lesson]!
  private lazy var vocabRepository = VocabRepositoryStub(book: book, lessons: lessons)
  
  override func setUp() {
    super.setUp()
    
    scheduler = TestScheduler(initialClock: 0)
    (book, lessons, _, _) = makeSampleBook()
  }
  
  override func tearDown() {
    scheduler.scheduleAt(1000) {
      self.subscription.dispose()
    }
    super.tearDown()
  }
  
  func test_init_callGetLesson() {
    let lesson = lessons[0]
    let _ = makeSut(book: book, lesson: lesson)
    XCTAssertTrue(vocabRepository.isGetLessonCalled)
  }
  
  func test_init_lessonIncludesVocabAndReadingPart_return3ChildViewModel() {
    let lesson = lessons[0]
    let sut = makeSut(book: book, lesson: lesson)
    
    let itemVmSpy = ItemVMSpy(observable: sut.childVC)
    
    XCTAssertEqual(itemVmSpy.childViewModel, [[.learnVocab, .readingPart, .listOfVocabs]])
  }
  
  func test_int_lessonIncludesVocabOnly_return2ChildViewModel() {
    let lesson = lessons[1]
    let sut = makeSut(book: book, lesson: lesson)
    
    let itemVmSpy = ItemVMSpy(observable: sut.childVC)
    XCTAssertEqual(itemVmSpy.childViewModel, [[.learnVocab, .listOfVocabs]])
  }
  
  func test_int_lessonIncludesReadingPartOnly_return1ChildViewModel() {
    let lesson = lessons[2]
    let sut = makeSut(book: book, lesson: lesson)
    
    let itemVmSpy = ItemVMSpy(observable: sut.childVC)
    XCTAssertEqual(itemVmSpy.childViewModel, [[.readingPart]])
  }
  
  func test_int_lessonNotIncludesBoth_returnEmpty() {
    let lesson = lessons[3]
    let sut = makeSut(book: book, lesson: lesson)
    
    let itemVmSpy = ItemVMSpy(observable: sut.childVC)
    XCTAssertEqual(itemVmSpy.childViewModel, [[]])
  }
  
  // For child view controllers
  func test_lessonWithVocabs_setLearnVocabViewModel() {
    let lesson = lessons[0]
    let sut = makeSut(book: book, lesson: lesson)
    
    let expectedResult = LessonDetailViewModel
      .ToDetailViewModelConverter
      .convertVocabsToLearnVocabItemVMs(vocabs: lesson.vocabs)
    
    let learnVocabSpy = LearnVocabSpy(observable: sut.oLearnVocabVItemiewModels)
    XCTAssertEqual(learnVocabSpy.viewModels, [expectedResult])
  }
  
  func test_lessonWithVocabs_setReadingPartViewModes() {
    let lesson = lessons[0]
    let sut = makeSut(book: book, lesson: lesson)
    
    let expectedResult = LessonDetailViewModel
      .ToDetailViewModelConverter
      .convertReadingPartToReadingPartItemVMs(readingPart: lesson.readingParts)
    
    let readingPartSpy = ReadingPartSpy(observable: sut.oReadingPartItemViewModels)
    XCTAssertEqual(readingPartSpy.viewModels, [expectedResult])
  }
  
  func test_lessonWithVocabs_setVocabListItemViewModels() {
    
    let lesson = lessons[0]
    let sut = makeSut(book: book, lesson: lesson)
    
    let expectedResult = LessonDetailViewModel
      .ToDetailViewModelConverter
      .convertVocabsToVocabListItemVMs(vocabs: lesson.vocabs)
    
    let vocabListSpy = VocabListSpy(observable: sut.oListOfVocabsItemViewModels)
    XCTAssertEqual(vocabListSpy.viewModels, [expectedResult])
  }
  
  func test_reload_callGetVocabs() {
    let lesson = lessons[0]
    let sut = makeSut(book: book, lesson: lesson)
    sut.reload()
    XCTAssertEqual(vocabRepository.numberOfGetLessonCalled, 2)
  }
  
  // Classes
  private func makeSut(book: Book, lesson: Lesson) -> LessonDetailViewModel {
    let sut = LessonDetailViewModel(bookID: book.id, lessonID: lesson.id, vocabRepository: vocabRepository)
    return sut
  }
  
  // Spy
  class ItemVMSpy {
    
    private let observable: Observable<[LessonDetailChildVC]>
    private let disposeBag = DisposeBag()
    
    private(set) var childViewModel: [[LessonDetailChildVC]] = []
    
    init(observable: Observable<[LessonDetailChildVC]>) {
      self.observable = observable
      
      self.observable
        .subscribe(onNext: { [weak self] vms in
          self?.childViewModel.append(vms)
        })
        .disposed(by: disposeBag)
    }
  }
  
  class LearnVocabSpy {
    
    private let observable: Observable<[LearnVocabItemViewModel]>
    private let disposeBag = DisposeBag()
    
    private(set) var viewModels: [[LearnVocabItemViewModel]] = []
    
    init(observable: Observable<[LearnVocabItemViewModel]>) {
      self.observable = observable
      
      observable
        .subscribe(onNext: { [weak self] vms in
          self?.viewModels.append(vms)
        })
        .disposed(by: disposeBag)
    }
    
  }
  
  class ReadingPartSpy {
    private let observable: Observable<[ReadingPartItemViewModel]>
    private let disposeBag = DisposeBag()
    
    private(set) var viewModels: [[ReadingPartItemViewModel]] = []
    
    init(observable: Observable<[ReadingPartItemViewModel]>) {
      self.observable = observable
      
      observable
        .subscribe(onNext: { [weak self] vms in
          self?.viewModels.append(vms)
        })
        .disposed(by: disposeBag)
    }
  }
  
  class VocabListSpy {
    private let observable: Observable<[VocabListItemViewModel]>
    private let disposeBag = DisposeBag()
    
    private(set) var viewModels: [[VocabListItemViewModel]] = []
    
    init(observable: Observable<[VocabListItemViewModel]>) {
      self.observable = observable
      
      observable
        .subscribe(onNext: { [weak self] vms in
          self?.viewModels.append(vms)
        })
        .disposed(by: disposeBag)
    }
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
    let lesson2 = Lesson(id: 2, name: "제1과 2", index: 2, translations: [.en: "Lesson 2", .vi: "Bải 2"], vocabs: vocabs, readingParts: [])
    let lesson3 = Lesson(id: 3, name: "제1과 3", index: 3, translations: [.en: "Lesson 3", .vi: "Bải 3"], vocabs: [], readingParts: [readingPart])
    let lesson4 = Lesson(id: 4, name: "제1과 4", index: 4, translations: [.en: "Lesson 4", .vi: "Bải 4"], vocabs: [], readingParts: [])
    let lesson5 = Lesson(id: 5, name: "제1과 5", index: 5, translations: [.en: "Lesson 5", .vi: "Bải 5"], vocabs: [], readingParts: [])
    
    let lessons = [lesson1, lesson2, lesson3, lesson4, lesson5]
    
    let book = Book(id: 1, name: "한국어와 한국문화\n 기조", thumbURL: nil, lessons: lessons)
    return (book, lessons, lesson1, vocabs)
  }
  
  private class VocabRepositoryStub: VocabRepository {
    
    private(set) var isGetLessonCalled = false
    private(set) var numberOfGetLessonCalled = 0
    
    private let book: Book
    private let lessons: [Lesson]
    
    init(book: Book, lessons: [Lesson]) {
      self.book = book
      self.lessons = lessons
    }
    
    func getListOfBook() -> [Book] {
      return []
    }
    
    func getListOfLesson(inBook id: Int) -> Observable<[Lesson]> {
      return scheduler.createHotObservable([
        Recorded.next(500, book.lessons)
        ]).asObservable()
    }
    
    func getLesson(inBook id: Int, lessonID: Int) -> Observable<Lesson> {
      isGetLessonCalled = true
      numberOfGetLessonCalled += 1
      guard let lesson = lessons.first(where: { $0.id == lessonID }) else {
        return Observable.empty()
      }
      return .just(lesson)
    }
    
    func getListOfVocabs(inBook bookID: Int, inLesson lessonID: Int) -> Observable<[Vocab]> {
      isGetLessonCalled = true
      guard let lesson = lessons.first(where: { $0.id == lessonID }) else {
        return Observable.empty()
      }
      return Observable.just(lesson.vocabs)
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
