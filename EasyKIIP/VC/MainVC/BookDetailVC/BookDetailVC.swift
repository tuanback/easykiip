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
  private lazy var adLoader = NativeAdLoader(adUnitID: adUnitID,
                                             numberOfAdsToLoad: numAdsToLoad,
                                             viewController: self,
                                             delegate: self)
  
  private let disposeBag = DisposeBag()
  
  private var isVCJustEntering = true
  
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
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if isVCJustEntering {
      isVCJustEntering = false
    }
    else {
      viewModel.reload()
    }
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
    adLoader.load()
  }
}

extension BookDetailVC: NativeAdLoaderDelegate {
  func adLoaderFinishLoading(ads: [GADUnifiedNativeAd]) {
    viewModel.addNativeAds(ads: ads)
  }
}
