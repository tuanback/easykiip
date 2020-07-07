//
//  AppDenpendencyContainer.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UserSession
import Purchases

class AppDependencyContainer {
  
  let userSessionRepository: UserSessionRepository
  
  init() {
    func makeUserSessionDataStore() -> UserSessionDataStore {
      return FirebaseUserSessionDataStore()
    }
    
    let dataStore = makeUserSessionDataStore()
    
    self.userSessionRepository = FirebaseUserSessionRepository(dataStore: dataStore)
    if let profile = self.userSessionRepository.readUserSession()?.profile {
      Purchases.shared.identify(profile.id) { (info, error) in
        if let e = error {
          print("Sign in error: \(e.localizedDescription)")
        } else {
          print("User \(profile.id) signed in")
        }
      }
    }
  }
  
  func makeLaunchVC() -> LaunchVC {
    func makeLaunchNavigator() -> LaunchNavigator {
      return LaunchNavigator(factory: self)
    }
    
    let viewModel = makeLaunchViewModel()
    let factory = makeLaunchNavigator()
    return LaunchVC(viewModel: viewModel, navigator: factory)
  }
  
  private func makeLaunchViewModel() -> LaunchViewModel {
    return LaunchViewModel(userSessionRepository: userSessionRepository)
  }
  
  func makeOnboardingVC() -> OnboardingVC {
    let dependencyContainer = OnboardingDependencyContainer(appDependencyContainer: self)
    return dependencyContainer.makeOnboardingVC()
  }
  
  func makeMainNavVC() -> MainNavVC {
    let dependencyContainer = SignedInDependencyContainer(appDenpendencyContainer: self)
    return dependencyContainer.makeMainNavVC()
  }
}

extension AppDependencyContainer: OnboardingVCFactory, MainNavConFactory { }
