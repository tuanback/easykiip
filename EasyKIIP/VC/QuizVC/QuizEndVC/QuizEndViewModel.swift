//
//  QuizEndViewModel.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import Firebase
import RxCocoa
import RxSwift

class QuizEndViewModel {
  
  var oAdViewHidden: Driver<Bool> {
    return rAdViewHidden.asDriver()
  }
  
  var oEndViewHidden: Driver<Bool> {
    return rEndViewHidden.asDriver()
  }
  
  var oAd: Observable<GADUnifiedNativeAd> {
    return rAd.compactMap { $0 }
  }
  
  var oDismiss: Observable<Void> {
    return rDismiss.asObservable()
  }
  
  var oNavigationEvent: Observable<NavigationEvent<QuizEndNavigator.Destination>> {
    return rNavigationEvent.asObservable()
  }
  
  private let rNavigationEvent = PublishRelay<NavigationEvent<QuizEndNavigator.Destination>>()
  
  private var rAdViewHidden = BehaviorRelay<Bool>(value: true)
  private var rEndViewHidden = BehaviorRelay<Bool>(value: false)
  
  private var rAd: BehaviorRelay<GADUnifiedNativeAd?>
  
  private var rDismiss = PublishRelay<Void>()
  
  private var ad: GADUnifiedNativeAd?
  private let isPaidUser: Bool
  
  init(ad: GADUnifiedNativeAd?, isPaidUser: Bool) {
    self.ad = ad
    self.rAd = BehaviorRelay<GADUnifiedNativeAd?>(value: ad)
    self.isPaidUser = isPaidUser
    
    if ad != nil {
      rAdViewHidden.accept(false)
      rEndViewHidden.accept(true)
    }
  }
  
  func handleCloseButtonClicked() {
    rDismiss.accept(())
  }
  
  func sholdLoadAds() -> Bool {
    return !isPaidUser
  }
  
  func shouldShowIntertitialAd() -> Bool {
    if isPaidUser {
      return false
    }
    return (ad == nil)
  }
  
  func isPremiumUser() -> Bool {
    return isPaidUser
  }
  
  func handleUpgradeToPremiumButtonClicked() {
    rNavigationEvent.accept(.push(destination: .payWall))
  }
  
}
