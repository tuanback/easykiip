//
//  MainViewModel.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UserSession
import EasyKIIPKit
import RxSwift
import RxCocoa
import Action

public struct BookItemViewModel: Equatable {
  let id: Int
  let name: String
  let thumbURL: URL?
}

public class MainViewModel {
  
  let userSessionRepository: UserSessionRepository
  let vocabRepository: VocabRepository
  
  var bookViewModels = BehaviorRelay<[BookItemViewModel]>(value: [])
  
  private var books: [Book] = []
  
  var oAvatarURL: Observable<URL?> {
    return rAvatarURL.asObservable()
  }
  private var rAvatarURL = BehaviorRelay<URL?>(value: nil)
  
  var oNavigation = PublishRelay<NavigationEvent<MainNavigator.Destination>>()
  
  public init(userSessionRepository: UserSessionRepository,
       vocabRepository: VocabRepository) {
    self.userSessionRepository = userSessionRepository
    self.vocabRepository = vocabRepository
    self.initBookList()
  }
  
  deinit {
    print("Deinit")
  }
  
  func reload() {
    if let avatarString = userSessionRepository.readUserSession()?.profile.avatar,
      let url = URL(string: avatarString) {
      rAvatarURL.accept(url)
    }
    else {
      rAvatarURL.accept(nil)
    }
  }
  
  private func initBookList() {
    books = vocabRepository.getListOfBook()
    let itemViewModels = convertToItemViewModel(books: books)
    bookViewModels.accept(itemViewModels)
  }
  
  func getNumberOfBooks() -> Int {
    if books.count == 0 {
      initBookList()
    }
    return books.count
  }
  
  private func convertToItemViewModel(books: [Book]) -> [BookItemViewModel] {
    return books.map(convertToItemViewModel(_:))
  }
  
  private func convertToItemViewModel(_ book: Book) -> BookItemViewModel {
    return BookItemViewModel(id: book.id, name: book.name, thumbURL: book.thumbURL)
  }
  
  func handleBookItemClicked(_ itemViewModel: BookItemViewModel) {
    if let book = books.first(where: { $0.id == itemViewModel.id   }) {
      oNavigation.accept(.push(destination: .bookDetail(bookID: book.id, bookName: book.name)))
    }
  }
  
  func handleSignoutClicked() {
    userSessionRepository.signOut()
    oNavigation.accept(.dismiss)
  }
  
  func handleSettingButtonClicked() {
    oNavigation.accept(.present(destination: .setting))
  }
  
  func handleSearchBarTextInput(_ searchText: String) -> [Vocab] {
    return vocabRepository.searchVocab(keyword: searchText)
  }
  
  func shouldLoadAds() -> Bool {
    return !userSessionRepository.isUserSubscribed()
  }
  
  func handleFinishLearning() {
    for book in books {
      for lesson in book.lessons {
        vocabRepository.saveLessonPracticeHistory(inBook: book.id, lessonID: lesson.id)
      }
    }
  }
}
