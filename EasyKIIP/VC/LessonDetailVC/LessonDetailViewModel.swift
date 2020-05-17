//
//  LessonDetailViewModel.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/17.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit

class LessonDetailViewModel {
  
  let book: Book
  let lesson: Lesson
  let vocabRepository: VocabRepository
  
  init(book: Book, lesson: Lesson, vocabRepository: VocabRepository) {
    self.book = book
    self.lesson = lesson
    self.vocabRepository = vocabRepository
  }
  
}
