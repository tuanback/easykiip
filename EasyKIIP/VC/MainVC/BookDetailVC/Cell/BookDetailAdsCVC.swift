//
//  BookDetailAdsCVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class BookDetailAdsCVC: UICollectionViewCell {
    
  private var adsView: AdsSmallTemplateView!
  
  private weak var nativeAds: GADUnifiedNativeAd?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configCell(_ nativeAds: GADUnifiedNativeAd) {
    self.nativeAds = nativeAds
    adsView.nativeAd = self.nativeAds
  }
  
  private func setupViews() {
    
    backgroundColor = UIColor.appBackground
    layer.shadowColor = UIColor.appShadowColor.cgColor
    layer.shadowOpacity = 0.25
    layer.shadowRadius = 3
    layer.shadowOffset = CGSize(width: 0, height: 0)
    layer.cornerRadius = 10
    
    adsView = AdsSmallTemplateView()
    addSubview(adsView)
    
    adsView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
  
}
