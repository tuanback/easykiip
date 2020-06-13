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
  static let loginLater = NSLocalizedString("Login later? ", bundle: Strings.languageBundle, comment: "")
  static let playAsGuest = NSLocalizedString("Learn As Guest", bundle: Strings.languageBundle, comment: "")
  
  static let today = NSLocalizedString("Today", bundle: Strings.languageBundle, comment: "")
  static let yesterday = NSLocalizedString("Yesterday", bundle: Strings.languageBundle, comment: "")
  static let daysAgo = NSLocalizedString("d ago", bundle: Strings.languageBundle, comment: "")
  
  static let learn = NSLocalizedString("Learn", bundle: Strings.languageBundle, comment: "")
  static let paragraph = NSLocalizedString("Paragraph", bundle: Strings.languageBundle, comment: "")
  static let vocabulary = NSLocalizedString("Vocabulary", bundle: Strings.languageBundle, comment: "")
  static let knew = NSLocalizedString("Knew", bundle: Strings.languageBundle, comment: "practice screen")
  
  static let adHelpULearnForFree = NSLocalizedString("This advertisement helps you to learn for free", bundle: Strings.languageBundle, comment: "practice screen")
  
  static let practiceMakePerfect = NSLocalizedString("Practice makes perfect. Practice every day will help your memory better", bundle: Strings.languageBundle, comment: "practice screen")
}

// Common
extension Strings {
  static let ok = NSLocalizedString("Okay", bundle: Strings.languageBundle, comment: "")
  static let quit = NSLocalizedString("Quit", bundle: Strings.languageBundle, comment: "")
  static let cancel = NSLocalizedString("Cancel", bundle: Strings.languageBundle, comment: "")
  static let watch = NSLocalizedString("Watch", bundle: Strings.languageBundle, comment: "")
  static let done = NSLocalizedString("Done", bundle: Strings.languageBundle, comment: "")
  static let continueStr = NSLocalizedString("Continue", bundle: Strings.languageBundle, comment: "")
  static let retry = NSLocalizedString("Retry", bundle: Strings.languageBundle, comment: "")
  static let settings = NSLocalizedString("Settings", bundle: Strings.languageBundle, comment: "")
  
  static let failed = NSLocalizedString("Failed", bundle: Strings.languageBundle, comment: "")
  static let failedToLoadVideo = NSLocalizedString("Failed to load video. Do you want to try again?", bundle: Strings.languageBundle, comment: "")
  
  static let account = NSLocalizedString("Account", bundle: Strings.languageBundle, comment: "")
  static let language = NSLocalizedString("Language", bundle: Strings.languageBundle, comment: "")
  
  static let logIn = NSLocalizedString("Log In", bundle: Strings.languageBundle, comment: "")
  static let logOut = NSLocalizedString("Log Out", bundle: Strings.languageBundle, comment: "")
  static let appLanguage = NSLocalizedString("App Language", bundle: Strings.languageBundle, comment: "")
}

// Errors
extension Strings {
  
  static let nothingNeedMorePractice = NSLocalizedString("Nothing needs more practice", bundle: Strings.languageBundle, comment: "")
  static let youAreMasteredAllVocabularies = NSLocalizedString("You are master all vocabularies. Great!", bundle: Strings.languageBundle, comment: "")
  
  static let areYouSureYouWantToQuit = NSLocalizedString("Are you sure you want to quit?", bundle: Strings.languageBundle, comment: "")
  
  static let outOfHeart = NSLocalizedString("Out of heart", bundle: Strings.languageBundle, comment: "")
  static let youRanOutOfTheHeart = NSLocalizedString("You ran out of the heart. Do you want to watch a video ads to refill the heart?", bundle: Strings.languageBundle, comment: "")
  static let heartsAreRefilled = NSLocalizedString("Heart are refilled", bundle: Strings.languageBundle, comment: "")
}
