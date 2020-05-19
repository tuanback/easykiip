//
//  LaunchVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UserSession

public class LaunchViewModel {
  
  public typealias Factory = MainNavigationControllerFactory & OnboardingVCFactory
  
  private let userSessionRepository: UserSessionRepository
  
  let oNavigation = PublishRelay<NavigationEvent>()
  
  let vcFactory: Factory
  
  init(userSessionRepository: UserSessionRepository, viewControllerFactory: Factory) {
    self.userSessionRepository = userSessionRepository
    self.vcFactory = viewControllerFactory
  }
  
  func start() {
    if let _ = userSessionRepository.readUserSession() {
      oNavigation.accept(.present(vc: vcFactory.makeMainNavVC()))
      return
    }
    
    oNavigation.accept(.present(vc: vcFactory.makeOnboardingVC()))
  }
  
}

public protocol MainNavigationControllerFactory {
  func makeMainNavVC() -> MainNavVC
}

public protocol OnboardingVCFactory {
  func makeOnboardingVC() -> OnboardingVC
}
