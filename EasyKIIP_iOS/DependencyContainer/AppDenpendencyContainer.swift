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
    
    let viewModel = makeLaunchViewModel()
    return LaunchVC(viewModel: viewModel, makeOnboardingVC: makeOnboardingVC)
  }
  
  private func makeLaunchViewModel() -> LaunchViewModel {
    return LaunchViewModel(userSessionRepository: userSessionRepository)
  }
  
  private func makeOnboardingVC() -> OnboardingVC {
    let viewModel = OnboardingVM()
    return OnboardingVC(viewModel: viewModel)
  }
  
  private func makeOnboardingVM() -> OnboardingVM {
    return OnboardingVM()
  }
}
