//
//  SignedInDependencyContainer.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UserSession
import EasyKIIPKit
import UIKit

public class SignedInDependencyContainer {
  
  let userSessionRepository: UserSessionRepository
  let vocabRepository: VocabRepository
  
  init(appDenpendencyContainer: AppDependencyContainer) {
    func makeRemoteAPI() -> VocabRemoteAPI {
      return FakeVocabRemoteAPI()
    }
    
    func makeVocabDataStore() -> VocabDataStore {
      return RealmDataStore()
    }
    
    func makeVocabRepository(userSessionRepo: UserSessionRepository) -> VocabRepository {
      let remoteAPI = makeRemoteAPI()
      let dataStore = makeVocabDataStore()
      let vocabRepository = KIIPVocabRepository(userSessionRepo: userSessionRepo,
                                                remoteAPI: remoteAPI,
                                                dataStore: dataStore)
      return vocabRepository
      
    }
    
    self.userSessionRepository = appDenpendencyContainer.userSessionRepository
    self.vocabRepository = makeVocabRepository(userSessionRepo: userSessionRepository)
  }
  
  deinit {
    print("Deinit")
  }
  
  func makeMainNavVC() -> MainNavVC {
    func makeMainNavNavigator() -> MainNavConNavigator {
      return MainNavConNavigator(factory: self)
    }
    
    let viewModel = MainNavViewModel()
    let mainNavVC = MainNavVC(viewModel: viewModel, navigator: makeMainNavNavigator())
    return mainNavVC
  }
  
  func makeMainVC() -> MainVC {
    func makeMainNavigator() -> MainNavigator {
      return MainNavigator(factory: self)
    }
    
    let viewModel = makeMainViewModel()
    let mainVC = MainVC(viewModel: viewModel,
                        navigator: makeMainNavigator())
    return mainVC
  }
  
  func makeMainViewModel() -> MainViewModel {
    let mainVM = MainViewModel(userSessionRepository: userSessionRepository, vocabRepository: vocabRepository)
    return mainVM
  }
  
  func makeBookDetailVC(bookID: Int, bookName: String) -> BookDetailVC {
    
    func makeViewModel(bookID: Int, bookName: String) -> BookDetailViewModel {
      return BookDetailViewModel(bookID: bookID, bookName: bookName, vocabRepository: vocabRepository)
    }
    
    let navigator = BookDetailNavigator(factory: self)
    let viewModel = makeViewModel(bookID: bookID, bookName: bookName)
    return BookDetailVC(viewModel: viewModel, navigator: navigator)
  }
  
  func makeLessonDetailVC(bookID: Int, lessonID: Int) -> LessonDetailVC {
    let viewModel = LessonDetailViewModel(bookID: bookID,
                                          lessonID: lessonID,
                                          vocabRepository: vocabRepository)
    let navigator = LessonDetailNavigator(factory: self)
    return LessonDetailVC(viewModel: viewModel, navigator: navigator)
  }
  
  func makeQuizNewWordVC(bookID: Int, lessonID: Int, vocabs: [Vocab]) -> QuizVC {
   
    // TODO: Need to change this code
    let randomVocabs: [Vocab] = []
    
    let questionMaker = NewWordQuestionMaker(createQuestionVocabs: vocabs, randomVocabs: randomVocabs, languageCode: AppSetting.languageCode)
    
    let quizEngine = KIIPQuizEngine(bookID: bookID, lessonID: lessonID, vocabs: vocabs, numberOfHeart: nil, questionMaker: questionMaker, vocabRepository: vocabRepository)
    let viewModel = QuizViewModel(quizEngine: quizEngine)
    
    let navigator = QuizNavigator(factory: self)
    return QuizVC(viewModel: viewModel, navigator: navigator)
  }
  
  func makeEndQuizVC() -> UIViewController {
    return UIViewController()
  }
  
  func makeVideoAdsVC() -> UIViewController {
    return UIViewController()
  }
  
}

extension SignedInDependencyContainer: MainVCFactory { }
extension SignedInDependencyContainer: BookDetailFactory { }
extension SignedInDependencyContainer: LessonDetailVCFactory { }
extension SignedInDependencyContainer: QuizNewWordVCFactory { }

extension SignedInDependencyContainer: EndQuizAdVCFactory { }
extension SignedInDependencyContainer: VideoAdsVCFactory { }
