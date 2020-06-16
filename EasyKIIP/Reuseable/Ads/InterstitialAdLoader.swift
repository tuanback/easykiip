//
//  InterstitialAdLoader.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/16.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import Firebase

class InterstitialAdLoader: NSObject {
  
  private var interstitial: GADInterstitial!
  private let adUnitID: String
  
  init(adUnitID: String) {
    self.adUnitID = adUnitID
    self.interstitial = GADInterstitial(adUnitID: adUnitID)
    super.init()
    self.interstitial.delegate = self
  }
  
  func load() {
    interstitial.load(GADRequest())
  }
  
  @discardableResult
  func present(viewController: UIViewController) -> Bool {
    if interstitial.isReady {
      interstitial.present(fromRootViewController: viewController)
      return true
    }
    return false
  }
  
}

extension InterstitialAdLoader: GADInterstitialDelegate {
  func interstitialDidDismissScreen(_ ad: GADInterstitial) {
    self.interstitial = GADInterstitial(adUnitID: adUnitID)
    self.interstitial.delegate = self
    load()
  }
}
