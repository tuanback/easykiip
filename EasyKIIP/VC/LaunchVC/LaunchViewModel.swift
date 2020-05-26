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
  
  private let userSessionRepository: UserSessionRepository
  
  let oNavigation = PublishRelay<NavigationEvent<LaunchNavigator.Destination>>()
  
  init(userSessionRepository: UserSessionRepository) {
    self.userSessionRepository = userSessionRepository
  }
  
  func start() {
    // First Time Launch
    if !AppValuesStorage.isNotFirstTimeLaunched {
      oNavigation.accept(.present(destination: .onboarding))
      return
    }
    
    oNavigation.accept(.present(destination: .main))
  }
  
}
