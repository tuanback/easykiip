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

public class MainNavViewModel {
  
  lazy var oNavigation = BehaviorRelay<NavigationEvent>(value: .push(vc: factory.makeMainVC()))
  
  let factory: MainVCFactory
  
  init(viewControllerFactory: MainVCFactory) {
    self.factory = viewControllerFactory
  }
}

public protocol MainVCFactory {
  func makeMainVC() -> MainVC
}
