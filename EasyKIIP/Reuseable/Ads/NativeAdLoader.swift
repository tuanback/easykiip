//
//  AdLoader.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol NativeAdLoaderDelegate: class {
  func adLoaderFinishLoading(ads: [GADUnifiedNativeAd])
}

class NativeAdLoader: NSObject {
  
  var isAdsReceived: Bool = false
  
  private let adUnitID: String
  private let numberOfAds: Int
  private weak var viewController: UIViewController?
  private weak var delegate: NativeAdLoaderDelegate?
  
  private var adLoader: GADAdLoader
  private var nativeAds = [GADUnifiedNativeAd]()
  
  init(adUnitID: String, numberOfAdsToLoad: Int,
       viewController: UIViewController?,
       delegate: NativeAdLoaderDelegate) {
    self.adUnitID = adUnitID
    self.numberOfAds = numberOfAdsToLoad
    self.viewController = viewController
    self.delegate = delegate
    
    let options = GADMultipleAdsAdLoaderOptions()
    options.numberOfAds = numberOfAds
    
    adLoader = GADAdLoader(adUnitID: adUnitID,
                           rootViewController: self.viewController,
                           adTypes: [.unifiedNative],
                           options: [options])
    super.init()
    adLoader.delegate = self
  }
  
  func load() {
    let request = GADRequest()
    adLoader.load(request)
  }
  
}

extension NativeAdLoader: GADUnifiedNativeAdLoaderDelegate {
  
  public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
    print("\(adLoader) failed with error: \(error.localizedDescription)")
  }
  
  public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
    print("Received native ad: \(nativeAd)")
    isAdsReceived = true
    nativeAds.append(nativeAd)
  }
  
  public func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
    delegate?.adLoaderFinishLoading(ads: nativeAds)
  }
}
