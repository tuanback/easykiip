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
      return FirebaseUserSessionDataStore()
    }
    
    let dataStore = makeUserSessionDataStore()
    
    self.userSessionRepository = FirebaseUserSessionRepository(dataStore: dataStore)
  }
  
  public func makeLaunchVC() -> LaunchVC {
    let viewModel = makeLaunchViewModel()
    return LaunchVC(viewModel: viewModel)
  }
  
  private func makeLaunchViewModel() -> LaunchViewModel {
    return LaunchViewModel(userSessionRepository: userSessionRepository, viewControllerFactory: self)
  }
  
  public func makeOnboardingVC() -> OnboardingVC {
    let dependencyContainer = OnboardingDependencyContainer(appDependencyContainer: self)
    return dependencyContainer.makeOnboardingVC()
  }
  
  public func makeMainNavVC() -> MainNavVC {
    let dependencyContainer = SignedInDependencyContainer(appDenpendencyContainer: self)
    return dependencyContainer.makeMainNavVC()
  }
}

extension AppDependencyContainer: MainNavigationControllerFactory, OnboardingVCFactory { }
