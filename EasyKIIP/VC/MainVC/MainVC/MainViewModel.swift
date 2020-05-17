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
  
  var oNavigation = PublishRelay<NavigationEvent<SignedInView>>()
  
  public init(userSessionRepository: UserSessionRepository,
       vocabRepository: VocabRepository) {
    self.userSessionRepository = userSessionRepository
    self.vocabRepository = vocabRepository
    self.initBookList()
  }
  
  deinit {
    print("Deinit")
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
      oNavigation.accept(.push(view: .bookDetail(book)))
    }
  }
  
  func handleSignoutClicked() {
    userSessionRepository.signOut()
    oNavigation.accept(.dismiss)
  }
}
