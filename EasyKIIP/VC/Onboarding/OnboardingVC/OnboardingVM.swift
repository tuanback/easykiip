//
//  OnboardingVM.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UserSession
import RxSwift
import RxCocoa
import Action

protocol SignedInResponder {
  func signedIn()
}

public protocol GoToLogInNavigator {
  func navigateToLogIn()
}

public class OnboardingVM: SignedInResponder, GoToLogInNavigator {
  
  lazy var oNavigation = BehaviorRelay<NavigationEvent>(value: .push(vc: factory.makeWelcomeVC()))
  
  public typealias Factory = WelcomeVCFactory & LoginVCFactory
  
  let factory: Factory
  
  init(viewControllerFactory: Factory) {
    self.factory = viewControllerFactory
  }
  
  public func navigateToLogIn() {
    oNavigation.accept(.push(vc: factory.makeLoginVC()))
  }
  
  func signedIn() {
    oNavigation.accept(.dismiss)
  }
  
}

public protocol WelcomeVCFactory {
  func makeWelcomeVC() -> WelcomeVC
}

public protocol LoginVCFactory {
  func makeLoginVC() -> LoginVC
}
