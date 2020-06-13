//
//  SettingSectionItem.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

enum SettingSectionItem {
  case account
  case language
  
  func toString() -> String {
    switch self {
    case .account:
      return Strings.account
    case .language:
      return Strings.language
    }
  }
}
