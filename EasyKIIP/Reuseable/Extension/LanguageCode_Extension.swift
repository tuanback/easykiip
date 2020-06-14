//
//  LanguageCode_Extension.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/14.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit

extension LanguageCode {
  
  func toString() -> String {
    switch self {
    case .en:
      return Strings.english
    case .vi:
      return Strings.vietnamese
    }
  }
  
}
