//
//  BookDetailVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleMobileAds

public class BookDetailVC: NiblessViewController {
  
  private let viewModel: BookDetailViewModel
  
  private lazy var adUnitID = AdsIdentifier.id(for: .bookDetailItem)
  
  let numAdsToLoad = 4
  
  var nativeAds = [GADUnifiedNativeAd]()
  
  var adLoader: GADAdLoader!
  
  init(viewModel: BookDetailViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  public override func loadView() {
    view = BookDetailRootView(viewModel: viewModel)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    startAdLoader()
  }
  
  private func startAdLoader() {
    
    let options = GADMultipleAdsAdLoaderOptions()
    options.numberOfAds = numAdsToLoad
    
    adLoader = GADAdLoader(adUnitID: adUnitID,
                           rootViewController: self,
                           adTypes: [.unifiedNative],
                           options: [options])
    adLoader.delegate = self
    adLoader.load(GADRequest())
  }
  
}

extension BookDetailVC: GADUnifiedNativeAdLoaderDelegate {
  
  public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
    print("\(adLoader) failed with error: \(error.localizedDescription)")
  }
  
  public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
    print("Received native ad: \(nativeAd)")

    // Add the native ad to the list of native ads.
    nativeAds.append(nativeAd)
  }
  
  public func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
    viewModel.addNativeAds(ads: nativeAds)
  }
}