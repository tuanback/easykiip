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
  
  var oNavigation = BehaviorRelay<NavigationEvent<OnboardingNavigator.Destination>>(value: .push(destination: .welcome))
  
  public func navigateToLogIn() {
    oNavigation.accept(.push(destination: .login))
  }
  
  func signedIn() {
    oNavigation.accept(.dismiss)
  }
  
}
