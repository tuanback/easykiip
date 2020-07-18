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
  case premiumUpgrade
  case appLanguage
  case contactUs
  case rateUs
  
  func toString() -> String {
    switch self {
    case .login:
      return Strings.logIn
    case .logOut:
      return Strings.logOut
    case .appLanguage:
      return Strings.appLanguage
    case .premiumUpgrade:
      return Strings.upgradeToPremium
    case .contactUs:
      return Strings.contactUs
    case .rateUs:
      return Strings.rateUs
    }
  }
}
