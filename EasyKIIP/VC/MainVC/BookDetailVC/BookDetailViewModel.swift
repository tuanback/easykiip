//
//  BookDetailViewModel.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/05.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import EasyKIIPKit
import SwiftDate

struct LessonItemViewModel: Equatable {
  let id: Int
  let name: String
  let translation: String
  let lessonIndex: Int
  let proficiency: UInt8
  let lastTimeLearnedFromToday: Int?
}

class BookDetailViewModel {
  
  private let book: Book
  private let vocabRepository: VocabRepository
  
  public var lessonViewModels: Observable<[LessonItemViewModel]>!
  
  private(set) var lessons = BehaviorRelay<[Lesson]>(value: [])
  private(set) var isLoading = BehaviorRelay<Bool>(value: false)
  
  private let disposeBag = DisposeBag()
  
  init(book: Book, vocabRepository: VocabRepository) {
    self.book = book
    self.vocabRepository = vocabRepository
    initLessons()
  }
  
  private func initLessons() {
    self.isLoading.accept(true)
    
    let observable = self.vocabRepository.getListOfLesson(in: book).share()
    
    observable
      .bind(to: lessons)
      .disposed(by: disposeBag)
    
    observable
      .subscribe(onNext: { [weak self] _ in
        self?.isLoading.accept(false)
      })
      .disposed(by: disposeBag)
    
    lessonViewModels = lessons.map(convertToLessonItemViewModels(lessons:))
  }
  
  private func convertToLessonItemViewModels(lessons: [Lesson]) -> [LessonItemViewModel] {
    return lessons.map(convertToLessonItemViewModel(lesson:))
  }
  
  private func convertToLessonItemViewModel(lesson: Lesson) -> LessonItemViewModel {
    let id = lesson.id
    let name = lesson.name
    let translation = lesson.translations[AppSetting.languageCode] ?? ""
    let index = lesson.index
    let proficiency = lesson.proficiency
    
    var lastTimeLearnedFromToday: Int? = nil
    
    if let date = lesson.lastTimeLearned {
      lastTimeLearnedFromToday = (Date() - date).in(.day)
    }
    
    return LessonItemViewModel(id: id,
                               name: name,
                               translation: translation,
                               lessonIndex: index,
                               proficiency: proficiency,
                               lastTimeLearnedFromToday: lastTimeLearnedFromToday)
  }
}
