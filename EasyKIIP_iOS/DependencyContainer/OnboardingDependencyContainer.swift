//
//  OnboardingDependencyContainer.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UserSession

class OnboardingDependencyContainer {
  
  let userSessionRepository: UserSessionRepository
  let onboardingViewModel: OnboardingVM
  
  init(appDependencyContainer: AppDependencyContainer) {
    self.userSessionRepository = appDependencyContainer.userSessionRepository
    self.onboardingViewModel = OnboardingVM()
  }
  
  func makeOnboardingVC() -> OnboardingVC {
    let makeWelcomeVC = {
      self.makeWelcomeVC()
    }
    
    let makeLoginVC = {
      self.makeLoginVC()
    }
    
    return OnboardingVC(viewModel: onboardingViewModel,
                        makeWelcomeVC: makeWelcomeVC,
                        makeLoginVC: makeLoginVC)
  }
  
  func makeLoginVC() -> LoginVC {
    let viewModel = makeLoginViewModel()
    return LoginVC(viewModel: viewModel)
  }
  
  private func makeLoginViewModel() -> LoginViewModel {
    let viewModel = LoginViewModel(userSessionRepository: userSessionRepository,
                                   signedInResponder: onboardingViewModel)
    return viewModel
  }
  
  func makeWelcomeVC() -> WelcomeVC {
    let viewModel = WelcomeViewModel(goToLogInNavigator: onboardingViewModel)
    return WelcomeVC(viewModel: viewModel)
  }
  
}
