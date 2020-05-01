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

public class WelcomeViewModel {
  
  private let gotoLogInNavigator: GoToLogInNavigator
  
  public init(goToLogInNavigator: GoToLogInNavigator) {
    self.gotoLogInNavigator = goToLogInNavigator
  }
  
  lazy var loginAction = CocoaAction { [weak self] in
    self?.gotoLogInNavigator.navigateToLogIn()
    return .just(())
  }
  
  
  
}
