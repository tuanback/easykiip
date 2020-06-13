//
//  AdsIdentifier.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/12.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

enum AdsType {
  case bookDetailItem
  case rewardVideo
}

struct AdsIdentifier {
  
  private struct App {
    static let nativeAds = "ca-app-pub-4377015897765379/2266520475"
    static let rewardAds = "ca-app-pub-4377015897765379/1785626982"
  }
  
  private struct Test {
    static let nativeAds = "ca-app-pub-3940256099942544/3986624511"
    static let rewardAds = "ca-app-pub-3940256099942544/1712485313"
  }
  
  static func id(for type: AdsType) -> String {
    
    switch type {
    case .bookDetailItem:
      #if DEBUG
      return Test.nativeAds
      #else
      return App.nativeAds
      #endif
    case .rewardVideo:
      #if DEBUG
      return Test.rewardAds
      #else
      return App.rewardAds
      #endif
    }
    
  }
  
}
