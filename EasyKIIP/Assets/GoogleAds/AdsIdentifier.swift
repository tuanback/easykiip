//
//  AdsIdentifier.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/12.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

enum AdsType {
  case onlyImageNativeAds
  case rewardVideo
  case interstitial
  case nativeAds
}

struct AdsIdentifier {
  
  // For production
  /*
  static let onlyImageNativeAds = "ca-app-pub-4377015897765379/3232086939"
  static let nativeAds = "ca-app-pub-4377015897765379/2266520475"
  static let rewardAds = "ca-app-pub-4377015897765379/1785626982"
  static let interstitial = "ca-app-pub-4377015897765379/5506106494"
  */
 
  // For test
  static let onlyImageNativeAds = "ca-app-pub-3940256099942544/3986624511"
  static let nativeAds = "ca-app-pub-3940256099942544/3986624511"
  static let rewardAds = "ca-app-pub-3940256099942544/1712485313"
  static let interstitial = "ca-app-pub-3940256099942544/4411468910"
  
  static func id(for type: AdsType) -> String {
    
    switch type {
    case .onlyImageNativeAds:
      return onlyImageNativeAds
    case .nativeAds:
      return nativeAds
    case .rewardVideo:
      return rewardAds
    case .interstitial:
      return interstitial
    }
    
  }
  
}
