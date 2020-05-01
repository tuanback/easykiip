//
//  AppDenpendencyContainer.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UserSession

public class AppDependencyContainer {
  
  let userSessionRepository: UserSessionRepository
  
  public init() {
    func makeUserSessionDataStore() -> UserSessionDataStore {
      return FakeUserSessionDataStore(hasToken: false)
    }
    
    func makeRemoteAPI() -> AuthRemoteAPI {
      return FakeAuthRemoteAPI()
    }
    
    let dataStore = makeUserSessionDataStore()
    let remoteAPI = makeRemoteAPI()
    self.userSessionRepository = KIIPUserSessionRepository(dataStore: dataStore, remoteAPI: remoteAPI)
  }
  
  public func makeLaunchVC() -> LaunchVC {
    let makeOnboardingVC = {
      return self.makeOnboardingVC()
    }
    
    let makeMainVC = {
      return self.makeMainVC()
    }
    
    let viewModel = makeLaunchViewModel()
    return LaunchVC(viewModel: viewModel, makeOnboardingVC: makeOnboardingVC, makeMainVC: makeMainVC)
  }
  
  private func makeLaunchViewModel() -> LaunchViewModel {
    return LaunchViewModel(userSessionRepository: userSessionRepository)
  }
  
  private func makeOnboardingVC() -> OnboardingVC {
    let dependencyContainer = OnboardingDependencyContainer(appDependencyContainer: self)
    return dependencyContainer.makeOnboardingVC()
  }
  
  private func makeMainVC() -> MainVC {
    let dependencyContainer = SignedInDependencyContainer(appDenpendencyContainer: self)
    return dependencyContainer.makeMainVC()
  }
}
