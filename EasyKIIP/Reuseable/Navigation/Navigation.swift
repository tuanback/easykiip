//
//  Navigation.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

enum NavigationEvent<T: AppView> {
  case push(view: T)
  case present(view: T)
  case dismiss
  case pop
}
