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
import Purchases

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
  
  static func == (lhs: ReadingPartItemViewModel, rhs: ReadingPartItemViewModel) -> Bool {
    return lhs.scriptName == rhs.scriptName && lhs.scriptNameTranslation == rhs.scriptNameTranslation
  }
  
  let readingPart: ReadingPart
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
  
  var oNavigationTitle: Driver<String> {
    rNavigagtionTitle.asDriver()
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
  
  var oNavigationEvent: Observable<NavigationEvent<LessonDetailNavigator.Destination>> {
    return rNavigationEvent.asObservable()
  }
  
  var oPracticeButtonHidden: Driver<Bool> {
    return rPracticeButtonHidden.asDriver()
  }
  
  var oIsLoading: Observable<Bool> {
    return rIsLoading.asObservable()
  }
  
  var oShowNoInternetAlert: Observable<Void> {
    return rShowNoInternetAlert.asObservable()
  }
  
  var oShowCannotLoadOffering: Observable<Void> {
    return rShowCannotLoadOffering.asObservable()
  }
  
  private let rNavigationEvent = PublishRelay<NavigationEvent<LessonDetailNavigator.Destination>>()
  private let rChildVC = BehaviorRelay<[LessonDetailChildVC]>(value: [])
  private let rVocabs = BehaviorRelay<[Vocab]>(value: [])
  private let rReadingParts = BehaviorRelay<[ReadingPart]>(value: [])
  private let rNavigagtionTitle = BehaviorRelay<String>(value: "")
  private let rPracticeButtonHidden = BehaviorRelay<Bool>(value: true)
  private let rIsLoading = BehaviorRelay<Bool>(value: false)
  private let rShowNoInternetAlert = PublishRelay<Void>()
  private let rShowCannotLoadOffering = PublishRelay<Void>()
  
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
    rIsLoading.accept(true)
    let observable = vocabRepository.getLesson(inBook: bookID, lessonID: lessonID).share(replay: 1, scope: .forever)
    
    let languageCode = AppSetting.languageCode
    
    observable.map { [weak self] (lesson) -> [LessonDetailChildVC] in
      defer {
        self?.rIsLoading.accept(false)
      }
      let vocabs = lesson.vocabs.filter { (vocab) -> Bool in
        vocab.translations[languageCode] != nil
      }
      let readingParts = lesson.readingParts.filter { (readingPart) -> Bool in
        readingPart.scriptTranslation[languageCode] != nil
      }
      
      if vocabs.count > 0 && readingParts.count > 0 {
        return [.learnVocab, .readingPart, .listOfVocabs]
      }
      else if vocabs.count > 0 {
        return [.learnVocab, .listOfVocabs]
      }
      else if readingParts.count > 0 {
        return [.readingPart]
      }
      return []
    }
    .bind(to: rChildVC)
    .disposed(by: disposeBag)
    
    observable.map {
      $0.name
    }
    .bind(to: rNavigagtionTitle)
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
    
    observable.map { [weak self] _ -> Bool in
      guard let strongSelf = self else { return true }
      let vocabs = strongSelf.vocabRepository.getListOfLowProficiencyVocab(inLesson: strongSelf.lessonID, upto: 10)
      return vocabs.count == 0
    }
    .bind(to: rPracticeButtonHidden)
    .disposed(by: disposeBag)
  }
  
  func handleItemViewModelClicked(viewModel: LearnVocabItemViewModel) {
    guard isAbleToStartLearning() else {
      rShowNoInternetAlert.accept(())
      return
    }
    
    rNavigationEvent.accept(.present(destination: .quizNewWord(bookID: bookID, lessonID: lessonID, vocabs: viewModel.vocabs)))
  }
  
  func handleReadingPartItemClicked(viewModel: ReadingPartItemViewModel) {
    guard isAbleToStartLearning() else {
      rShowNoInternetAlert.accept(())
      return
    }
    
    rNavigationEvent.accept(.push(destination: .paragraph(readingPart: viewModel.readingPart)))
  }
  
  func handlePracticeButtonClicked() {
    guard isAbleToStartLearning() else {
      rShowNoInternetAlert.accept(())
      return
    }
    
    let vocabs = vocabRepository.getListOfLowProficiencyVocab(inLesson: lessonID, upto: 10)
    rNavigationEvent.accept(.present(destination: .quizPractice(bookID: bookID, lessonID: lessonID, vocabs: vocabs)))
  }
  
  func handleUpgradeToPremiumButtonClicked() {
    rNavigationEvent.accept(.present(destination: .payWall))
  }
  
  private func isAbleToStartLearning() -> Bool {
    // TODO: If paid user or user with internet turn on => Can start learning
    if InternetStateProvider.isInternetConnected {
      return true
    }
    
    return false
  }
  
  func handleFinishLearning() {
    vocabRepository.saveLessonPracticeHistory(inBook: bookID, lessonID: lessonID)
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
  
}

struct ToDetailViewModelConverter {
  
  static let numberOfItemForOneTimeLearn = 8
  
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
        readingPart: $0,
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
        i += 1
        tempVocabs.removeAll()
        continue
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
    var proficiency: UInt8 = 0
    
    let learnedVocabs = vocabs.filter({ $0.lastTimeTest != nil })
    if learnedVocabs.count == vocabs.count {
      proficiency = calculateProficiency(vocabs: vocabs)
    }
    return LearnVocabItemViewModel(index: index, proficiency: proficiency, vocabs: vocabs)
  }
  
  private static func calculateProficiency(vocabs: [Vocab]) -> UInt8 {
    
    let total: Int = vocabs.reduce(0) { (result, vocab) in
      result + Int(vocab.proficiency)
    }
    
    return UInt8(total / vocabs.count)
    
  }
}
