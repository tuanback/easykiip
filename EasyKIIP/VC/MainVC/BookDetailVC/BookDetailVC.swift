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
import RxSwift
import RxCocoa

public class BookDetailVC: NiblessViewController {
  
  private let viewModel: BookDetailViewModel
  private let navigator: BookDetailNavigator
  
  private lazy var adUnitID = AdsIdentifier.id(for: .bookDetailItem)
  private let numAdsToLoad = 4
  private var nativeAds = [GADUnifiedNativeAd]()
  private var adLoader: GADAdLoader!
  
  private let disposeBag = DisposeBag()
  
  init(viewModel: BookDetailViewModel,
       navigator: BookDetailNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
  }
  
  public override func loadView() {
    view = BookDetailRootView(viewModel: viewModel)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
    startAdLoader()
  }
  
  private func observeViewModel() {
    viewModel.oNavigationTitle
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    viewModel.oNavigation
      .subscribe(onNext: { [weak self] event in
        guard let strongSelf = self else { return }
        switch event {
        case .push(let destination):
          strongSelf.navigator.navigate(from: strongSelf, to: destination, type: .push)
        case .present(let destination):
          strongSelf.navigator.navigate(from: strongSelf, to: destination, type: .present)
        case .pop:
          strongSelf.navigationController?.popViewController(animated: true)
        case .dismiss:
          strongSelf.dismiss(animated: true, completion: nil)
        }
      })
    .disposed(by: disposeBag)
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
