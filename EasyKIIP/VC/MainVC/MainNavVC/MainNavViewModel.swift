//
//  MainNavViewModel.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/02.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import EasyKIIPKit

enum SignedInView: AppView {
  case main
  case bookDetail(Book?)
  
  public func hidesNavigationBar() -> Bool {
    switch self {
    case .main:
      return false
    case .bookDetail:
      return false
    }
  }
}

public class MainNavViewModel {
  
  var oNavigation = BehaviorRelay<NavigationEvent<SignedInView>>(value: .push(view: .main))
  
  init() {}
}
