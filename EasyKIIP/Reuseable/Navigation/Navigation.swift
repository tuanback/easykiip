//
//  Navigation.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

enum NavigationEvent<T> {
  case push(destination: T)
  case present(destination: T)
  case dismiss
  case pop
}
