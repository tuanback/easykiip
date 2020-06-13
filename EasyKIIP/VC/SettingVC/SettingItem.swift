//
//  SettingItem.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

enum SettingItem {
  
  case login
  case logOut
  case appLanguage
  
  func toString() -> String {
    switch self {
    case .login:
      return Strings.logIn
    case .logOut:
      return Strings.logOut
    case .appLanguage:
      return Strings.appLanguage
    }
  }
}
