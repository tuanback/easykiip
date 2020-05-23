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
  
  var oNavigation = BehaviorRelay<NavigationEvent<MainNavConNavigator.Destination>>(value: .push(destination: .main))
  
  init() {}
}
