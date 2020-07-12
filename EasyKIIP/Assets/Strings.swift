//
//  Strings.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit

private class LanguageBundleManager {
  
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
    self.bundle = bundle
    return bundle
  }
}

public struct Strings {
  
  private static var bundleManager = LanguageBundleManager()
  
  private static var languageBundle: Bundle {
    return bundleManager.getBundle()
  }
  
  static var logo: String {
    NSLocalizedString("Easy KIIP", bundle: Strings.languageBundle, comment: "")
  }
  static var onboardingTitle: String {
    NSLocalizedString("Easiest way to pass KIIP", bundle: Strings.languageBundle, comment: "")
  }
  static var onboardingMessage: String {
    NSLocalizedString("10 minutes per day, that's all you need", bundle: Strings.languageBundle, comment: "")
  }
  static var login: String {
    NSLocalizedString("Login", bundle: Strings.languageBundle, comment: "")
  }
  static var loginLater: String {
    NSLocalizedString("Login later? ", bundle: Strings.languageBundle, comment: "")
  }
  static var playAsGuest: String {
    NSLocalizedString("Learn As Guest", bundle: Strings.languageBundle, comment: "")
  }
  static var today: String {
    NSLocalizedString("Today", bundle: Strings.languageBundle, comment: "")
  }
  static var yesterday: String {
    NSLocalizedString("Yesterday", bundle: Strings.languageBundle, comment: "")
  }
  static var daysAgo: String {
    NSLocalizedString("d ago", bundle: Strings.languageBundle, comment: "")
  }
  static var learn: String {
    NSLocalizedString("Learn", bundle: Strings.languageBundle, comment: "")
  }
  static var paragraph: String {
    NSLocalizedString("Paragraph", bundle: Strings.languageBundle, comment: "")
  }
  static var vocabulary: String {
    NSLocalizedString("Vocabulary", bundle: Strings.languageBundle, comment: "")
  }
  static var grammar: String {
    NSLocalizedString("Grammar", bundle: Strings.languageBundle, comment: "")
  }
  static var usage: String {
    NSLocalizedString("Usage", bundle: Strings.languageBundle, comment: "Cách sử dụng")
  }
  static var example: String {
    NSLocalizedString("Example", bundle: Strings.languageBundle, comment: "Ví dụ")
  }
  static var sameMeaningGrammar: String {
    NSLocalizedString("Same Meaning Grammar", bundle: Strings.languageBundle, comment: "")
  }
  static var knew: String {
    NSLocalizedString("Knew", bundle: Strings.languageBundle, comment: "practice screen")
  }
  
  static var adHelpULearnForFree: String {
    NSLocalizedString("This advertisement helps you to learn for free", bundle: Strings.languageBundle, comment: "practice screen")
  }
  static var practiceMakePerfect: String {
    NSLocalizedString("Practice makes perfect. Practice every day will help your memory better", bundle: Strings.languageBundle, comment: "practice screen")
  }
  
  static var noInternetConnection: String {
    NSLocalizedString("No Internet Connection", bundle: Strings.languageBundle, comment: "")
  }
  
  static var turnOnInternetMessage: String {
    NSLocalizedString("Please turn the internet on to learn for free or upgrade to Premium user to study offline", bundle: Strings.languageBundle, comment: "")
  }
  
  static var turnInternetOnThenTryAgain: String {
    NSLocalizedString("Please turn the internet on then try again", bundle: Strings.languageBundle, comment: "")
  }
  
  static var includes : String {
    NSLocalizedString("Includes", bundle: Strings.languageBundle, comment: "")
  }
  static var freeTrail: String {
    NSLocalizedString("free trail.", bundle: Strings.languageBundle, comment: "")
  }
  static var cancelBefore: String {
    NSLocalizedString("Cancel before", bundle: Strings.languageBundle, comment: "")
  }
  static var nothingWillBeBilled: String {
    NSLocalizedString(" and nothing will be billed", bundle: Strings.languageBundle, comment: "")
  }
}

// Common
extension Strings {
  static var ok: String {
    NSLocalizedString("Okay", bundle: Strings.languageBundle, comment: "")
  }
  static var quit: String {
    NSLocalizedString("Quit", bundle: Strings.languageBundle, comment: "")
  }
  static var cancel: String {
    NSLocalizedString("Cancel", bundle: Strings.languageBundle, comment: "")
  }
  static var watch: String {
    NSLocalizedString("Watch", bundle: Strings.languageBundle, comment: "")
  }
  static var done: String {
    NSLocalizedString("Done", bundle: Strings.languageBundle, comment: "")
  }
  static var continueStr: String {
    NSLocalizedString("Continue", bundle: Strings.languageBundle, comment: "")
  }
  static var retry: String {
    NSLocalizedString("Retry", bundle: Strings.languageBundle, comment: "")
  }
  static var settings: String {
    NSLocalizedString("Settings", bundle: Strings.languageBundle, comment: "")
  }
  static var failed: String {
    NSLocalizedString("Failed", bundle: Strings.languageBundle, comment: "")
  }
  static var failedToLoadVideo: String {
    NSLocalizedString("Failed to load video. Do you want to try again?", bundle: Strings.languageBundle, comment: "")
  }
  static var error: String {
    NSLocalizedString("Error", bundle: Strings.languageBundle, comment: "")
  }
  static var loading: String {
    NSLocalizedString("LOADING...", bundle: Strings.languageBundle, comment: "")
  }
  static var restorePurchases: String {
    NSLocalizedString("RESTORE PURCHASES", bundle: Strings.languageBundle, comment: "")
  }
  static var termsOfService: String {
    NSLocalizedString("Terms of Service", bundle: Strings.languageBundle, comment: "")
  }
  static var privacyPolicy: String {
    NSLocalizedString("Privacy Policy", bundle: Strings.languageBundle, comment: "")
  }
  static var and: String {
    NSLocalizedString("and", bundle: Strings.languageBundle, comment: "")
  }
  static var save: String {
    NSLocalizedString("Save", bundle: Strings.languageBundle, comment: "")
  }
  static var noOfferingsFound: String {
    NSLocalizedString("No offerings found.", bundle: Strings.languageBundle, comment: "")
  }
  static var endOfTrail: String {
    NSLocalizedString("end of trial", bundle: Strings.languageBundle, comment: "")
  }
  
  static var account: String {
    NSLocalizedString("Account", bundle: Strings.languageBundle, comment: "")
  }
  static var upgradeToPremium: String {
    NSLocalizedString("Premium Upgrade", bundle: Strings.languageBundle, comment: "")
  }
  
  static var lifeTime: String {
    NSLocalizedString("LifeTime", bundle: Strings.languageBundle, comment: "")
  }
  static var oneTime: String {
    NSLocalizedString("One Time", bundle: Strings.languageBundle, comment: "")
  }
  static var year: String {
    NSLocalizedString("Year", bundle: Strings.languageBundle, comment: "")
  }
  static var months: String {
    NSLocalizedString("Months", bundle: Strings.languageBundle, comment: "")
  }
  static var month: String {
    NSLocalizedString("Month", bundle: Strings.languageBundle, comment: "")
  }
  static var week: String {
    NSLocalizedString("Week", bundle: Strings.languageBundle, comment: "")
  }
  static var day: String {
    NSLocalizedString("day", bundle: Strings.languageBundle, comment: "")
  }
  static var monthShort: String {
    NSLocalizedString("mo", bundle: Strings.languageBundle, comment: "")
  }
  static var weekShort: String {
    NSLocalizedString("wk", bundle: Strings.languageBundle, comment: "")
  }
  
  static var language: String {
    NSLocalizedString("Language", bundle: Strings.languageBundle, comment: "")
  }
  
  static var logIn: String {
    NSLocalizedString("Log In", bundle: Strings.languageBundle, comment: "")
  }
  static var logOut: String {
    NSLocalizedString("Log Out", bundle: Strings.languageBundle, comment: "")
  }
  static var appLanguage: String {
    NSLocalizedString("App Language", bundle: Strings.languageBundle, comment: "")
  }
  static var korean: String {
    NSLocalizedString("Korean", bundle: Strings.languageBundle, comment: "")
  }
  
  static var accountExplaination: String {
    NSLocalizedString("Log in to save and synchronize your learning progress between multiple devices", bundle: Strings.languageBundle, comment: "")
  }
  
  static var searchVocabOrTranslation: String {
    NSLocalizedString("Search vocab or translation", bundle: Strings.languageBundle, comment: "")
  }
  
  static var vietnamese = "Tiếng Việt"
  static var english = "English"
}

extension Strings {
  static var benefit_unlockEverything: String {
    NSLocalizedString("Unlock Everything", bundle: Strings.languageBundle, comment: "")
  }
  static var benefit_learnOffline: String {
    NSLocalizedString("✓ Learn offline", bundle: Strings.languageBundle, comment: "")
  }
  static var benefit_noAds: String {
    NSLocalizedString("✓ No advertisement", bundle: Strings.languageBundle, comment: "")
  }
  static var benefit_synchronizeBetweenMultipleDevices: String {
    NSLocalizedString("✓ Learn and synchronize learning history on multiple devices", bundle: Strings.languageBundle, comment: "")
  }
}

// Errors
extension Strings {
  
  static var nothingNeedMorePractice: String {
    NSLocalizedString("Nothing needs more practice", bundle: Strings.languageBundle, comment: "")
  }
  static var youAreMasteredAllVocabularies: String {
    NSLocalizedString("You are master all vocabularies. Great!", bundle: Strings.languageBundle, comment: "")
  }
  static var areYouSureYouWantToQuit: String {
    NSLocalizedString("Are you sure you want to quit?", bundle: Strings.languageBundle, comment: "")
  }
  static var outOfHeart: String {
    NSLocalizedString("Out of heart", bundle: Strings.languageBundle, comment: "")
  }
  static var youRanOutOfTheHeart: String {
    NSLocalizedString("You ran out of the heart. Do you want to watch a video ads to refill the heart?", bundle: Strings.languageBundle, comment: "")
  }
  static var heartsAreRefilled: String {
    NSLocalizedString("Heart are refilled", bundle: Strings.languageBundle, comment: "")
  }
}
