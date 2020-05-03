//
//  BookDetailViewModelTests.swift
//  EasyKIIPTests
//
//  Created by Tuan on 2020/05/03.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import EasyKIIPKit

/*
class BookDetailViewModel {
  
  private let book: Book
  private let vocabRepository: VocabRepository
  
  var lessons = BehaviorRelay<[Lesson]>(value: [])
  
  private let disposeBag = DisposeBag()
  
  init(book: Book, vocabRepository: VocabRepository) {
    self.book = book
    self.vocabRepository = vocabRepository
    vocabRepository
      .getLessons(in: book)
      .bind(to: self.lessons)
      .disposed(by: disposeBag)
  }
}

class BookDetailViewModelTests: XCTestCase {

  func testInit() {
    let book = Book(id: 0)
    let vocabRepository = VocabRepositoryStub()
    let sut = BookDetailViewModel(book: book, vocabRepository: vocabRepository)
    let lessons = LesssonSpy(observable: sut.lessons.asObservable())
    
    XCTAssertEqual(lessons.values, [[Lesson(id: 0)]])
  }
  
  private class LesssonSpy {
    
    private(set) var values: [[Lesson]] = []
    private let disposeBag = DisposeBag()
    
    init(observable: Observable<[Lesson]>) {
      observable
        .subscribe(onNext: { [weak self] lessons in
          self?.values.append(lessons)
        })
        .disposed(by: disposeBag)
    }
    
  }
  
  private class VocabRepositoryStub: VocabRepository {
    func getLessons(in book: Book) -> Observable<[Lesson]> {
      return Observable<[Lesson]>.just([Lesson(id: 0)])
    }
  }
}
 */
