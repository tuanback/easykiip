//
//  QuizEndVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class QuizEndVC: NiblessViewController {
  
  private let viewModel: QuizEndViewModel
  
  private let disposeBag = DisposeBag()
  private var didShowInterstitialAd = false
  
  private lazy var adLoader = InterstitialAdLoader(adUnitID: AdsIdentifier.id(for: .interstitial), delegate: self)
  
  init(viewModel: QuizEndViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = QuizEndRootView(viewModel: viewModel)
    observeViewModel()
    loadAds()
  }
  
  private func loadAds() {
    if viewModel.sholdLoadAds() {
      adLoader.load()
    }
  }
  
  private func observeViewModel() {
    viewModel.oDismiss
      .subscribe(onNext: { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
  }
  
}

extension QuizEndVC: InterstitialAdLoaderDelegate {
  func interstitialAdLoaderDidClose() {}
  
  func interstitialAdLoaderDidReceiveAd() {
    guard !didShowInterstitialAd && viewModel.shouldShowIntertitialAd() else { return }
    didShowInterstitialAd = true
    adLoader.present(viewController: self)
  }
}
