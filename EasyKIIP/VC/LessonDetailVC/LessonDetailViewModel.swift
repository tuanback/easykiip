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

struct LearnVocabItemViewModel {
  let index: Int
  let proficiency: UInt8
  let vocabs: [Vocab]
}

struct ReadingPartItemViewModel: Equatable {
  let scriptName: String
  let scriptNameTranslation: String
}

struct VocabListItemViewModel: Equatable {
  let id: Int
  let word: String
  let wordTranslation: String
}

class LessonDetailViewModel {
  
  var childVC: Observable<[LessonDetailChildVC]> {
    return rChildVC.asObservable()
  }
  
  var oLearnVocabVItemiewModels: Observable<[LearnVocabItemViewModel]> {
    return rVocabs.map { [weak self] (vocabs) in
      guard let strongSelf = self else {
        return []
      }
      return strongSelf.createLearnVocabViewModels(from: vocabs)
    }
  }
  
  var oReadingPartItemViewModels: Observable<[ReadingPartItemViewModel]> {
    return rReadingParts.map { [weak self] (readingParts) in
      guard let strongSelf = self else {
        return []
      }
      
      return strongSelf.createReadingPartViewModels(from: readingParts)
    }
  }
  
  var oListOfVocabsItemViewModels: Observable<[VocabListItemViewModel]> {
    return rVocabs.map { [weak self] (vocabs) in
      guard let strongSelf = self else {
        return []
      }
      
      return strongSelf.createListOfVocabsViewModels(from: vocabs)
    }
  }
  
  private let rChildVC = BehaviorRelay<[LessonDetailChildVC]>(value: [])
  private let rVocabs = BehaviorRelay<[Vocab]>(value: [])
  private let rReadingParts = BehaviorRelay<[ReadingPart]>(value: [])
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
  
  func reload() {
    getVocabs()
  }
  
  private func getVocabs() {
    let observable = vocabRepository.getLesson(inBook: bookID, lessonID: lessonID).share(replay: 1, scope: .forever)
    
    observable.map { (lesson) -> [LessonDetailChildVC] in
      if lesson.vocabs.count > 0 && lesson.readingParts.count > 0 {
        return [.learnVocab, .readingPart, .listOfVocabs]
      }
      else if lesson.vocabs.count > 0 {
        return [.learnVocab, .listOfVocabs]
      }
      else if lesson.readingParts.count > 0 {
        return [.readingPart]
      }
      return []
    }
    .bind(to: rChildVC)
    .disposed(by: disposeBag)
    
    observable.map {
      return $0.vocabs
    }
    .bind(to: rVocabs)
    .disposed(by: disposeBag)
    
    observable.map {
      return $0.readingParts
    }
    .bind(to: rReadingParts)
    .disposed(by: disposeBag)
  }
  
  private func createLearnVocabViewModels(from vocabs: [Vocab]) -> [LearnVocabItemViewModel] {
    // TODO: Create list to learn
    return ToDetailViewModelConverter.convertVocabsToLearnVocabItemVMs(vocabs: vocabs)
  }
  
  private func createReadingPartViewModels(from readingParts: [ReadingPart]) -> [ReadingPartItemViewModel] {
    return ToDetailViewModelConverter.convertReadingPartToReadingPartItemVMs(readingPart: readingParts)
  }
  
  private func createListOfVocabsViewModels(from vocabs: [Vocab]) -> [VocabListItemViewModel] {
    return ToDetailViewModelConverter.convertVocabsToVocabListItemVMs(vocabs: vocabs)
  }
  
  struct ToDetailViewModelConverter {
    
    static let numberOfItemForOneTimeLearn = 5
    
    static func convertVocabsToVocabListItemVMs(vocabs: [Vocab]) -> [VocabListItemViewModel] {
      return vocabs.map {
        return VocabListItemViewModel(id: $0.id,
                                      word: $0.word,
                                      wordTranslation: $0.translations[AppSetting.languageCode] ?? "")
      }
    }
    
    static func convertReadingPartToReadingPartItemVMs(readingPart: [ReadingPart]) -> [ReadingPartItemViewModel] {
      return readingPart.map {
        return ReadingPartItemViewModel(
          scriptName: $0.scriptName,
          scriptNameTranslation: $0.scriptNameTranslation[AppSetting.languageCode] ?? "")}
    }
    
    static func convertVocabsToLearnVocabItemVMs(vocabs: [Vocab]) -> [LearnVocabItemViewModel] {
      
      var viewModels: [LearnVocabItemViewModel] = []
      var i = 0
      var collectionID = 0
      
      var tempVocabs: [Vocab] = []
      
      while i < vocabs.count {
        if (i + 1) % numberOfItemForOneTimeLearn == 0 {
          tempVocabs.append(vocabs[i])
          collectionID += 1
          let viewModel = convertVocabsToLearnVocabItemVMs(index: collectionID, vocabs: tempVocabs)
          viewModels.append(viewModel)
          tempVocabs.removeAll()
        }
        
        tempVocabs.append(vocabs[i])
        i += 1
      }
      
      if !tempVocabs.isEmpty {
        collectionID += 1
        let viewModel = convertVocabsToLearnVocabItemVMs(index: collectionID, vocabs: tempVocabs)
        viewModels.append(viewModel)
        tempVocabs.removeAll()
      }
      
      return viewModels
    }
    
    private static func convertVocabsToLearnVocabItemVMs(index: Int, vocabs: [Vocab]) -> LearnVocabItemViewModel {
      let proficiency = calculateProficiency(vocabs: vocabs)
      return LearnVocabItemViewModel(index: index, proficiency: proficiency, vocabs: vocabs)
    }
    
    private static func calculateProficiency(vocabs: [Vocab]) -> UInt8 {
      
      let total: Int = vocabs.reduce(0) { (result, vocab) in
        result + Int(vocab.proficiency)
      }
      
      return UInt8(total / vocabs.count)
      
    }
  }
  
}
