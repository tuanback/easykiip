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
    return LessonDetailVC(viewModel: viewModel)
  }
  
}

extension SignedInDependencyContainer: MainVCFactory { }
extension SignedInDependencyContainer: BookDetailFactory { }
extension SignedInDependencyContainer: LessonDetailVCFactory { }
