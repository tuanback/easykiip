//
//  InterstitialAdLoader.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/16.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import Firebase

protocol InterstitialAdLoaderDelegate: class {
  func interstitialAdLoaderDidClose()
  func interstitialAdLoaderDidReceiveAd()
}

class InterstitialAdLoader: NSObject {
  
  private var interstitial: GADInterstitial!
  private let adUnitID: String
  
  private weak var delegate: InterstitialAdLoaderDelegate?
  
  var isReady: Bool {
    return interstitial.isReady
  }
  
  init(adUnitID: String, delegate: InterstitialAdLoaderDelegate?) {
    self.adUnitID = adUnitID
    self.interstitial = GADInterstitial(adUnitID: adUnitID)
    self.delegate = delegate
    super.init()
    self.interstitial.delegate = self
  }
  
  func load() {
    let request = GADRequest()
    interstitial.load(request)
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
    self.delegate?.interstitialAdLoaderDidClose()
  }
  
  func interstitialDidReceiveAd(_ ad: GADInterstitial) {
    self.delegate?.interstitialAdLoaderDidReceiveAd()
  }
}
