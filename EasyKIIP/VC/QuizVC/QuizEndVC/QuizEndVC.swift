//
//  QuizEndVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import SwiftRater
import UIKit

class QuizEndVC: NiblessViewController {
  
  private let viewModel: QuizEndViewModel
  private let navigator: QuizEndNavigator
  
  private let disposeBag = DisposeBag()
  private var didShowInterstitialAd = false
  
  private lazy var adLoader = InterstitialAdLoader(adUnitID: AdsIdentifier.id(for: .interstitial), delegate: self)
  
  init(viewModel: QuizEndViewModel, navigator: QuizEndNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
  }
  
  override func loadView() {
    view = QuizEndRootView(viewModel: viewModel)
    observeViewModel()
    loadAds()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    SwiftRater.check()
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
    
    viewModel.oNavigationEvent
      .subscribe(onNext: { [weak self] event in
        guard let strongSelf = self else { return }
        switch event {
        case .dismiss:
          self?.dismiss(animated: true, completion: nil)
        case .pop:
          self?.navigationController?.popViewController(animated: true)
        case .present(let destination):
          self?.navigator.navigate(from: strongSelf, to: destination, type: .present)
        case .push(let destination):
          self?.navigator.navigate(from: strongSelf, to: destination, type: .push)
        }
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
