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
  
  static let logo = NSLocalizedString("Easy KIIP", bundle: Strings.languageBundle, comment: "")
  static let onboardingTitle = NSLocalizedString("Easiest way to pass KIIP", bundle: Strings.languageBundle, comment: "")
  static let onboardingMessage = NSLocalizedString("10 minutes per day, that's all you need", bundle: Strings.languageBundle, comment: "")
  static let login = NSLocalizedString("Login", bundle: Strings.languageBundle, comment: "")
  
  static let today = NSLocalizedString("Today", bundle: Strings.languageBundle, comment: "")
  static let yesterday = NSLocalizedString("Yesterday", bundle: Strings.languageBundle, comment: "")
  static let daysAgo = NSLocalizedString("d ago", bundle: Strings.languageBundle, comment: "")
  
  static let learn = NSLocalizedString("Learn", bundle: Strings.languageBundle, comment: "")
  static let paragraph = NSLocalizedString("Paragraph", bundle: Strings.languageBundle, comment: "")
  static let vocabulary = NSLocalizedString("Vocabulary", bundle: Strings.languageBundle, comment: "")
  
}
