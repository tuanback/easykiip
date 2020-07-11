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
  
  private let bookID: Int
  private let vocabRepository: VocabRepository
  private let isPaidUser: Bool
  
  public var oNavigation = PublishRelay<NavigationEvent<BookDetailNavigator.Destination>>()
  
  public var oNavigationTitle = BehaviorRelay<String>(value: "")
  public var itemViewModels: Observable<[BookDetailItemViewModel]>!
  
  public var oNumberOfLessons: Observable<Int> {
    return lessons.map { $0.count }
  }
  
  private(set) var lessons = BehaviorRelay<[Lesson]>(value: [])
  private(set) var nativeAds = BehaviorRelay<[GADUnifiedNativeAd]>(value: [])
  private(set) var isLoading = BehaviorRelay<Bool>(value: false)
  
  private var disposeBag = DisposeBag()
  
  init(bookID: Int, bookName: String, vocabRepository: VocabRepository, isPaidUser: Bool) {
    self.bookID = bookID
    self.isPaidUser = isPaidUser
    self.vocabRepository = vocabRepository
    var name = bookName
    if bookName.contains("\n") {
      name = String(bookName.split(separator: "\n").last ?? "")
    }
    oNavigationTitle.accept(name)
    setupItemViewModels()
    initLessons()
  }
  
  func reload() {
    disposeBag = DisposeBag()
    initLessons()
  }
  
  func handleViewModelSelected(itemVM: LessonItemViewModel) {
    guard let lesson = lessons.value.first(where: { $0.id == itemVM.id }) else {
      return
    }
    
    oNavigation.accept(.push(destination: .lessonDetail(bookID: bookID, lessonID: lesson.id)))
  }
  
  func shouldLoadAds() -> Bool {
    return !isPaidUser
  }
  
  private func initLessons() {
    self.isLoading.accept(true)
    
    let observable = self.vocabRepository.getListOfLesson(inBook: bookID).share(replay: 1, scope: .whileConnected)
    
    observable
      .bind(to: lessons)
      .disposed(by: disposeBag)
    
    observable
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
        
        let adsPosition: [Int] = [3, 8, 14, 20]
        
        while i < lessons.count {
          if i > 0 && adsPosition.contains(i + 1) && j < ads.count {
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
  
  func handleSearchBarTextInput(_ searchText: String) -> [Vocab] {
    return vocabRepository.searchVocab(keyword: searchText)
  }
  
  func addNativeAds(ads: [GADUnifiedNativeAd]) {
    nativeAds.accept(ads)
  }
  
  func handleFinishLearning() {
    for lesson in lessons.value {
      vocabRepository.saveLessonPracticeHistory(inBook: bookID, lessonID: lesson.id)
    }
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
