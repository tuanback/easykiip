//
//  LessonDetailViewModel.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/17.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit
import RxSwift
import RxCocoa

enum LessonDetailChildVC {
  case learnVocab
  case readingPart
  case listOfVocabs
}

class LessonDetailViewModel {
  
  var childVC: Observable<[LessonDetailChildVC]> {
    return rVocabs.filter { $0.count > 0 }.map { _ in [.learnVocab, .listOfVocabs] }
  }
  
  private let rVocabs = BehaviorRelay<[Vocab]>(value: [])
  private let disposeBag = DisposeBag()
  
  let bookID: Int
  let lessonID: Int
  let vocabRepository: VocabRepository
  
  init(bookID: Int, lessonID: Int, vocabRepository: VocabRepository) {
    self.bookID = bookID
    self.lessonID = lessonID
    self.vocabRepository = vocabRepository
    getVocabs()
  }
  
  private func getVocabs() {
    vocabRepository.getListOfVocabs(inBook: bookID, inLesson: lessonID)
    .bind(to: rVocabs)
    .disposed(by: disposeBag)
  }
  
}
