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
    let makeMainVC = {
      self.makeMainVC()
    }
    
    let viewModel = MainNavViewModel()
    let mainNavVC = MainNavVC(viewModel: viewModel, makeMainVC: makeMainVC)
    return mainNavVC
  }
  
  func makeMainVC() -> MainVC {
    let factory: (Book) -> (BookDetailVC) = { book in
      return self.makeBookDetailVC(book: book)
    }
    
    let viewModel = makeMainViewModel()
    let mainVC = MainVC(viewModel: viewModel,
                        bookDetailVCFactory: factory)
    return mainVC
  }
  
  func makeMainViewModel() -> MainViewModel {
    let mainVM = MainViewModel(userSessionRepository: userSessionRepository, vocabRepository: vocabRepository)
    return mainVM
  }
  
  func makeBookDetailVC(book: Book) -> BookDetailVC {
    
    func makeViewModel(book: Book) -> BookDetailViewModel {
      return BookDetailViewModel(book: book, vocabRepository: vocabRepository)
    }
    
    let viewModel = makeViewModel(book: book)
    return BookDetailVC(viewModel: viewModel)
  }
  
}
