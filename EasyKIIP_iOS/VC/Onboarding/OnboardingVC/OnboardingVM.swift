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

protocol SignedInResponder {
  func singedIn()
}

enum OnboardingView: AppView {
  case login
}

public class OnboardingVM: SignedInResponder {
  
  var oNavigation = PublishRelay<NavigationEvent>()
  
  func logInButtonClicked() {
    oNavigation.accept(.push(view: OnboardingView.login))
  }
  
  func singedIn() {
    oNavigation.accept(.dismiss)
  }
  
}
