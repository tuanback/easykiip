//
//  AdsSmallTemplateView.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/17.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SnapKit

class AdsSmallTemplateView: GADUnifiedNativeAdView {
  
  override var nativeAd: GADUnifiedNativeAd? {
    didSet {
      updateViews()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("Not supported")
  }
  
  private func setupViews() {
    
    let mediaViewContainer = UIView()
    mediaViewContainer.backgroundColor = UIColor.clear
    
    let mediaView = GADMediaView()
    mediaViewContainer.addSubview(mediaView)
    
    self.mediaView = mediaView
    
    let iconViewContainer = UIView()
    iconViewContainer.backgroundColor = UIColor.clear
    iconViewContainer.isHidden = true
    
    let iconView = UIImageView()
    iconView.contentMode = .scaleAspectFit
    self.iconView = iconView
    
    iconViewContainer.addSubview(iconView)
    
    let headlineView = UILabel()
    headlineView.numberOfLines = 0
    headlineView.font = UIFont.appFontRegular(ofSize: 13)
    headlineView.textColor = UIColor.appLabelBlack
    headlineView.textAlignment = .left
    headlineView.adjustsFontSizeToFitWidth = true
    headlineView.minimumScaleFactor = 0.6
    
    self.headlineView = headlineView
    
    let labelAd = UILabel()
    labelAd.font = UIFont.appFontMedium(ofSize: 10)
    labelAd.textColor = UIColor.appBackground
    labelAd.backgroundColor = UIColor(hexString: "E4BE59")
    labelAd.text = "Ad"
    labelAd.textAlignment = .center
    labelAd.layer.cornerRadius = 5
    
    let bodyView = UILabel()
    bodyView.font = UIFont.appFontRegular(ofSize: 12)
    bodyView.textColor = UIColor.appSecondaryLabel
    bodyView.textAlignment = .left
    bodyView.adjustsFontSizeToFitWidth = true
    bodyView.minimumScaleFactor = 0.6
    bodyView.numberOfLines = 0
    self.bodyView = bodyView
    
    let ratingView = UIImageView()
    ratingView.contentMode = .scaleAspectFit
    self.starRatingView = ratingView
    
    let priceLabel = UILabel()
    priceLabel.font = UIFont.appFontMedium(ofSize: 10)
    priceLabel.textColor = UIColor.appLabelBlack
    self.priceView = priceLabel
    
    let adSV = UIStackView(arrangedSubviews: [labelAd, ratingView, priceLabel, UIView()])
    adSV.axis = .horizontal
    adSV.spacing = 3
    adSV.alignment = .fill
    adSV.distribution = .fill
    
    let callToActionView = UIButton()
    callToActionView.backgroundColor = UIColor.appRed
    callToActionView.setTitleColor(UIColor.white, for: .normal)
    callToActionView.titleLabel?.font = UIFont.appFontMedium(ofSize: 14)
    callToActionView.layer.cornerRadius = 5
    self.callToActionView = callToActionView
    
    headlineView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    headlineView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    adSV.setContentHuggingPriority(.defaultHigh, for: .vertical)
    adSV.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    bodyView.setContentHuggingPriority(.defaultLow, for: .vertical)
    bodyView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
 
    let textContainerSV = UIStackView(arrangedSubviews: [headlineView,
                                                         adSV,
                                                         bodyView])
    textContainerSV.axis = .vertical
    textContainerSV.spacing = 3
    textContainerSV.distribution = .fill
    textContainerSV.alignment = .fill
    
    let iconSV = UIStackView(arrangedSubviews: [iconViewContainer, textContainerSV])
    iconSV.axis = .horizontal
    iconSV.spacing = 2
    iconSV.distribution = .fill
    iconSV.alignment = .fill
    
    let rightSV = UIStackView(arrangedSubviews: [iconSV,
                                                 callToActionView])
    rightSV.axis = .vertical
    rightSV.spacing = 8
    rightSV.distribution = .fill
    rightSV.alignment = .fill
    
    let containerSV = UIStackView(arrangedSubviews: [mediaViewContainer, rightSV])
    containerSV.axis = .horizontal
    containerSV.spacing = 8
    containerSV.distribution = .fill
    containerSV.alignment = .fill
    
    addSubview(containerSV)
  
    mediaViewContainer.snp.makeConstraints { (make) in
      make.width.equalTo(120)
    }
    
    mediaView.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      make.width.equalToSuperview()
      make.height.equalTo(mediaView.snp.width)
    }
    
    iconViewContainer.snp.makeConstraints { (make) in
      make.width.equalTo(30)
    }
    
    iconView.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(headlineView)
      make.width.equalToSuperview()
      make.height.equalTo(iconView.snp.width)
    }
    
    containerSV.snp.makeConstraints { (make) in
      make.top.equalToSuperview().inset(15)
      make.bottom.equalToSuperview().inset(10)
      make.leading.equalToSuperview().inset(10)
      make.trailing.equalToSuperview().inset(10)
    }
    
    labelAd.snp.makeConstraints { (make) in
      make.width.equalTo(20)
    }
    
    callToActionView.snp.makeConstraints { (make) in
      make.height.equalTo(25)
    }
    
    iconView.snp.makeConstraints { (make) in
      make.width.equalTo(iconView.snp.height).multipliedBy(0.9)
    }
  }
  
  private func updateViews() {
    guard let nativeAd = self.nativeAd else { return }
    
    // Populate the native ad view with the native ad assets.
    // The headline and mediaContent are guaranteed to be present in every native ad.
    (headlineView as? UILabel)?.text = nativeAd.headline

    mediaView?.mediaContent = nativeAd.mediaContent
    // These assets are not guaranteed to be present. Check that they are before
    // showing or hiding them.
    (bodyView as? UILabel)?.text = nativeAd.body
    bodyView?.isHidden = nativeAd.body == nil

    (callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    callToActionView?.isHidden = nativeAd.callToAction == nil

    /*
    (iconView as? UIImageView)?.image = nativeAd.icon?.image
    iconView?.isHidden = nativeAd.icon == nil
    */
    
 
    (starRatingView as? UIImageView)?.image = imageOfStars(from:nativeAd.starRating)
    starRatingView?.isHidden = nativeAd.starRating == nil

    (priceView as? UILabel)?.text = nativeAd.price
    priceView?.isHidden = nativeAd.price == nil
    
    (advertiserView as? UILabel)?.text = nativeAd.advertiser
    advertiserView?.isHidden = nativeAd.advertiser == nil

    // In order for the SDK to process touch events properly, user interaction should be disabled.
    callToActionView?.isUserInteractionEnabled = false
    
  }
  
  /// Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
  /// if the star rating is less than 3.5 stars.
  func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
    guard let rating = starRating?.doubleValue else {
      return nil
    }
    if rating >= 5 {
      return UIImage(named: "stars_5")
    } else if rating >= 4.5 {
      return UIImage(named: "stars_4_5")
    } else if rating >= 4 {
      return UIImage(named: "stars_4")
    } else if rating >= 3.5 {
      return UIImage(named: "stars_3_5")
    } else {
      return nil
    }
  }
  
}
