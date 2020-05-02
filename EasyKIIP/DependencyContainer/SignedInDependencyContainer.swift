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
      return VocabDataStoreInMemory()
    }
    func makeVocabRepository() -> VocabRepository {
      let remoteAPI = makeRemoteAPI()
      let dataStore = makeVocabDataStore()
      let vocabRepository = KIIPVocabRepository(remoteAPI: remoteAPI, dataStore: dataStore)
      return vocabRepository
      
    }
    self.userSessionRepository = appDenpendencyContainer.userSessionRepository
    self.vocabRepository = makeVocabRepository()
  }
  
  func makeMainNavVC() -> MainNavVC {
    let makeMainVC = {
      self.makeMainVC()
    }
    
    let viewModel = MainNavViewModel()
    let mainNavVC = MainNavVC(viewModel: viewModel, makeMainVC: makeMainVC)
    return mainNavVC
  }
  
  func makeMainVC() -> MainVC {
    let viewModel = makeMainViewModel()
    let mainVC = MainVC(viewModel: viewModel)
    return mainVC
  }
  
  func makeMainViewModel() -> MainViewModel {
    let mainVM = MainViewModel(userSessionRepository: userSessionRepository, vocabRepository: vocabRepository)
    return mainVM
  }
  
}
