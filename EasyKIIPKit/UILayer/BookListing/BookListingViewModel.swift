//
//  BookListingViewModel.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

class BookListingViewModel {
  
  private let vocabRepository: VocabRepository
  
  init(vocabRepository: VocabRepository) {
    self.vocabRepository = vocabRepository
  }
  
  func getBookList() -> [Book] {
    vocabRepository.getListOfBook()
  }
  
}
