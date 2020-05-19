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

enum OnboardingView: AppView {
  case welcome
  case login
  
  public func hidesNavigationBar() -> Bool {
    switch self {
    case .welcome:
      return true
    case .login:
      return false
    }
  }
}

public class OnboardingVM: SignedInResponder, GoToLogInNavigator {
  
  var oNavigation = BehaviorRelay<NavigationEvent<OnboardingView>>(value: .push(view: .welcome))
  
  public func navigateToLogIn() {
    oNavigation.accept(.push(view: .login))
  }
  
  func signedIn() {
    oNavigation.accept(.dismiss)
  }
  
}
