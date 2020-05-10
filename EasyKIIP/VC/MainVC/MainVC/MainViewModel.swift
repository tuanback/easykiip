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

public struct BookItemViewModel: Equatable {
  let id: Int
  let name: String
  let thumbURL: URL?
}

public class MainViewModel {
  
  let userSessionRepository: UserSessionRepository
  let vocabRepository: VocabRepository
  
  lazy var bookViewModels = makeObservableOfBookItemViewModel()
  
  private var oBooks = BehaviorRelay<[Book]>(value: [])
  
  public init(userSessionRepository: UserSessionRepository,
       vocabRepository: VocabRepository) {
    self.userSessionRepository = userSessionRepository
    self.vocabRepository = vocabRepository
    self.initBookList()
  }
  
  private func initBookList() {
    let books = vocabRepository.getListOfBook()
    oBooks.accept(books)
  }
  
  func getNumberOfBooks() -> Int {
    if oBooks.value.count == 0 {
      initBookList()
    }
    return oBooks.value.count
  }
  
  private func makeObservableOfBookItemViewModel() -> Observable<[BookItemViewModel]> {
    return oBooks
      .map(convertToItemViewModel(books:))
      .asObservable()
  }
  
  private func convertToItemViewModel(books: [Book]) -> [BookItemViewModel] {
    return books.map(convertToItemViewModel(_:))
  }
  
  private func convertToItemViewModel(_ book: Book) -> BookItemViewModel {
    return BookItemViewModel(id: book.id, name: book.name, thumbURL: book.thumbURL)
  }
}
