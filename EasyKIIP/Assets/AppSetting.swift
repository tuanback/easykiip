//
//  AppSetting.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit

public struct AppSetting {
  
  /// Save app language settings
  public static var languageCode: LanguageCode {
    get {
      if let code = UserDefaults.standard.string(forKey: "AppSetting_LanguageCode"),
        let languageCode = LanguageCode(rawValue: code) {
        return languageCode
      }
      return .en
    }
    
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: "AppSetting_LanguageCode")
    }
  }
}
