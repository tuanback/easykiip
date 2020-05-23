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
    func makeVocabRepository(userSession: UserSession) -> VocabRepository {
      let remoteAPI = makeRemoteAPI()
      let dataStore = makeVocabDataStore()
      let vocabRepository = KIIPVocabRepository(userSession: userSession, remoteAPI: remoteAPI, dataStore: dataStore)
      return vocabRepository
      
    }
    
    self.userSessionRepository = appDenpendencyContainer.userSessionRepository
    let userSession = self.userSessionRepository.readUserSession()!
    self.vocabRepository = makeVocabRepository(userSession: userSession)
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
    
    let viewModel = makeViewModel(bookID: bookID, bookName: bookName)
    return BookDetailVC(viewModel: viewModel)
  }
  
}

extension SignedInDependencyContainer: MainVCFactory { }
extension SignedInDependencyContainer: BookDetailFactory { }
