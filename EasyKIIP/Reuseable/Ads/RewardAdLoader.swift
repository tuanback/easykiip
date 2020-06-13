//
//  RewardAdLoader.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Firebase
import Foundation
import UIKit

protocol RewardAdLoaderDelegate: class {
  func rewardAdLoader(userDidEarn reward: GADAdReward)
}

class RewardAdLoader: NSObject {
  
  private let adUnitID: String
  private var adLoader: GADRewardedAd
  
  private weak var delegate: RewardAdLoaderDelegate?
  
  init(adUnitID: String, delegate: RewardAdLoaderDelegate) {
    self.adUnitID = adUnitID
    self.adLoader = GADRewardedAd(adUnitID: adUnitID)
    self.delegate = delegate
    super.init()
    self.load()
  }
  
  func load() {
    adLoader.load(GADRequest()) { (error) in
      print("Reward based video ad received")
      if let err = error {
        print(err)
      }
    }
  }
  
  func present(viewController: UIViewController) -> Bool {
    if adLoader.isReady {
      adLoader.present(fromRootViewController: viewController, delegate: self)
      return true
    }
    return false
  }
  
}

extension RewardAdLoader: GADRewardedAdDelegate {
  
  func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
    print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    delegate?.rewardAdLoader(userDidEarn: reward)
  }
  
  func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
    print("Reward based video ad started playing.")
  }
  
  func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
    print("Reward based video ad is closed.")
    self.adLoader = GADRewardedAd(adUnitID: adUnitID)
    self.load()
  }
  
  func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
    print("Reward based video ad failed to load.")
  }
  
}
