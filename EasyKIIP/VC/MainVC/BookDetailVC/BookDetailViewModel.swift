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
import GoogleMobileAds

enum BookDetailItemViewModel {
  case item(viewModel: LessonItemViewModel)
  case ads(viewModel: GADUnifiedNativeAd)
}

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
  
  public var oNavigationTitle = BehaviorRelay<String>(value: "")
  public var itemViewModels: Observable<[BookDetailItemViewModel]>!
  
  private(set) var lessons = BehaviorRelay<[Lesson]>(value: [])
  private(set) var nativeAds = BehaviorRelay<[GADUnifiedNativeAd]>(value: [])
  private(set) var isLoading = BehaviorRelay<Bool>(value: false)
  
  private let disposeBag = DisposeBag()
  
  init(book: Book, vocabRepository: VocabRepository) {
    self.book = book
    self.vocabRepository = vocabRepository
    oNavigationTitle.accept(book.name)
    setupItemViewModels()
    initLessons()
  }
  
  func handleViewModelSelected(itemVM: LessonItemViewModel) {
    guard let lesson = lessons.value.first(where: { $0.id == itemVM.id }) else {
      return
    }
    
    // TODO: Open detail views
    
  }
  
  private func initLessons() {
    self.isLoading.accept(true)
    
    let observable = self.vocabRepository.getListOfLesson(in: book).share(replay: 1, scope: .whileConnected)
    
    observable
      .bind(to: lessons)
      .disposed(by: disposeBag)
    
    observable
      .debug()
      .subscribe(onNext: { [weak self] _ in
        self?.isLoading.accept(false)
      })
      .disposed(by: disposeBag)
  }
  
  private func setupItemViewModels() {
    itemViewModels = Observable.combineLatest(lessons.asObservable(), nativeAds.asObservable())
      .map { [weak self] (lessons, ads) -> [BookDetailItemViewModel] in
        guard let strongSelf = self else { return [] }
        let lessonsItemVM = strongSelf.convertToLessonItemViewModels(lessons: lessons)
        
        var results: [BookDetailItemViewModel] = []
        
        var i = 0
        var j = 0
        
        while i < lessons.count {
          if i > 0 && (i + 1) % 5 == 0 && j < ads.count {
            results.append(.item(viewModel: lessonsItemVM[i]))
            results.append(.ads(viewModel: ads[j]))
            j += 1
          }
          else {
            results.append(.item(viewModel: lessonsItemVM[i]))
          }
          
          i += 1
        }
        
        return results
    }
  }
  
  func addNativeAds(ads: [GADUnifiedNativeAd]) {
    nativeAds.accept(ads)
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
