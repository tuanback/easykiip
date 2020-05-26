//
//  WelcomeViewModel.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action

class WelcomeViewModel {
  
  private let gotoLogInNavigator: GoToLogInNavigator
  private let signedInLaterResponder: SignedInLaterResponder
  
  init(goToLogInNavigator: GoToLogInNavigator,
       signedInLaterResponder: SignedInLaterResponder) {
    self.gotoLogInNavigator = goToLogInNavigator
    self.signedInLaterResponder = signedInLaterResponder
  }
  
  lazy var loginAction = CocoaAction { [weak self] in
    self?.gotoLogInNavigator.navigateToLogIn()
    return Observable.empty()
  }
  
  lazy var signedInLaterAction = CocoaAction { [weak self] in
    self?.signedInLaterResponder.signInLater()
    return Observable.empty()
  }
  
}
