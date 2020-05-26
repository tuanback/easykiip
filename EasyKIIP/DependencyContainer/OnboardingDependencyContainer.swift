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
    func makeOnboardingNavigator() -> OnboardingNavigator {
      return OnboardingNavigator(factory: self)
    }
    
    return OnboardingVC(viewModel: onboardingViewModel,
                        navigator: makeOnboardingNavigator())
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
    let viewModel = WelcomeViewModel(goToLogInNavigator: onboardingViewModel,
                                     signedInLaterResponder: onboardingViewModel)
    return WelcomeVC(viewModel: viewModel)
  }
  
}

extension OnboardingDependencyContainer: LoginVCFactory, WelcomeVCFactory { }
