//
//  Strings.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit

private struct LanguageBundleManager {
  
  private var languageCode = AppSetting.languageCode
  private var bundle: Bundle? = nil
  
  func getBundle() -> Bundle {

    if let bundle = self.bundle {
      if languageCode == AppSetting.languageCode {
        return bundle
      }
    }
    
    let languageCode = AppSetting.languageCode
    guard let path = Bundle.main.path(forResource: languageCode.rawValue, ofType: "lproj"),
      let bundle = Bundle(path: path) else {
        return Bundle.main
    }
    return bundle
    
  }
}

public struct Strings {
  
  private static var languageBundle: Bundle {
    return LanguageBundleManager().getBundle()
  }
  
  static let logo = NSLocalizedString("Logo", bundle: Strings.languageBundle, comment: "")
  static let onboardingTitle = NSLocalizedString("Easiest way to pass KIIP", bundle: Strings.languageBundle, comment: "")
  static let onboardingMessage = NSLocalizedString("10 minutes per day, passing Korean Immigration and Integration Program program has never been easier", bundle: Strings.languageBundle, comment: "")
  static let login = NSLocalizedString("Login", bundle: Strings.languageBundle, comment: "")
}
