//
//  QuizEndRootView.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Firebase
import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class QuizEndRootView: NiblessView {
  
  // If there is no ad
  private let viewEndQuiz = UIView()
  private let labelEndQuizText = UILabel()
  private let buttonContinue = UIButton()
  
  // If there is ad
  private let viewAdContainer = UIView()
  private lazy var buttonClose = UIButton()
  private lazy var adView = AdsLargeTemplateView()
  private lazy var labelAdExplaination = UILabel()
  
  private let disposeBag = DisposeBag()
  
  private let viewModel: QuizEndViewModel
  
  init(viewModel: QuizEndViewModel,
       frame: CGRect = .zero) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    
    backgroundColor = UIColor.appBackground
    
    addSubview(viewEndQuiz)
    addSubview(viewAdContainer)
    
    labelEndQuizText.text = Strings.practiceMakePerfect
    labelEndQuizText.font = UIFont.appFontMedium(ofSize: 20)
    labelEndQuizText.textColor = UIColor.appSecondaryLabel
    labelEndQuizText.minimumScaleFactor = 0.1
    labelEndQuizText.adjustsFontSizeToFitWidth = true
    labelEndQuizText.textAlignment =  .center
    labelEndQuizText.numberOfLines = 0
    
    buttonContinue.backgroundColor = UIColor.appRed
    buttonContinue.setTitle(Strings.continueStr, for: .normal)
    buttonContinue.setTitleColor(UIColor.white, for: .normal)
    buttonContinue.layer.cornerRadius = 10
    buttonContinue.titleLabel?.font = UIFont.appFontMedium(ofSize: 18)
    
    buttonContinue.addTarget(self, action: #selector(handleCloseButtonClicked(sender:)), for: .touchUpInside)
    
    viewEndQuiz.addSubview(labelEndQuizText)
    viewEndQuiz.addSubview(buttonContinue)
    
    viewEndQuiz.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    viewAdContainer.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    buttonContinue.snp.makeConstraints { (make) in
      make.bottom.equalTo(safeAreaInsets.bottom).inset(32)
      make.height.equalTo(60)
      make.leading.equalToSuperview().inset(32)
      make.trailing.equalToSuperview().inset(32)
    }
    
    labelEndQuizText.snp.makeConstraints { (make) in
      make.top.equalTo(safeAreaInsets.top).inset(32)
      make.bottom.equalTo(buttonContinue.snp.top).inset(16)
      make.leading.equalToSuperview().inset(32)
      make.trailing.equalToSuperview().inset(32)
    }
    
    viewModel.oAdViewHidden
      .drive(viewAdContainer.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel.oEndViewHidden
      .drive(viewEndQuiz.rx.isHidden)
      .disposed(by: disposeBag)
   
    viewModel.oAd
      .observeOn(MainScheduler.asyncInstance)
      .take(1)
      .subscribe(onNext: { [weak self] ad in
        self?.setupAdViews(ad: ad)
      })
    .disposed(by: disposeBag)
  }
  
  private func setupAdViews(ad: GADUnifiedNativeAd) {
    
    buttonClose.setImage(UIImage(named: IconName.close), for: .normal)
    buttonClose.addTarget(self, action: #selector(handleCloseButtonClicked(sender:)), for: .touchUpInside)
    
    labelAdExplaination.text = Strings.adHelpULearnForFree
    labelAdExplaination.font = UIFont.appFontMedium(ofSize: 17)
    labelAdExplaination.textColor = UIColor.appSecondaryLabel
    labelAdExplaination.minimumScaleFactor = 0.1
    labelAdExplaination.adjustsFontSizeToFitWidth = true
    labelAdExplaination.textAlignment =  .center
    labelAdExplaination.numberOfLines = 0
    
    let viewSeparator = UIView()
    viewSeparator.backgroundColor = UIColor.appSystemGray3
    
    viewAdContainer.addSubview(buttonClose)
    viewAdContainer.addSubview(labelAdExplaination)
    viewAdContainer.addSubview(viewSeparator)
    viewAdContainer.addSubview(adView)
    
    buttonClose.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(16)
      make.top.equalTo(safeAreaInsets.top).inset(40)
      make.size.equalTo(44)
    }
    
    labelAdExplaination.snp.makeConstraints { (make) in
      make.leading.equalTo(buttonClose.snp.trailing).offset(8)
      make.trailing.equalToSuperview().inset(68)
      make.centerY.equalTo(buttonClose.snp.centerY)
      make.height.greaterThanOrEqualTo(buttonClose.snp.height)
    }
    
    viewSeparator.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(0.5)
      make.top.equalTo(labelAdExplaination.snp.bottom).offset(8)
    }
    
    adView.snp.makeConstraints { (make) in
      make.top.equalTo(viewSeparator.snp.bottom).offset(16)
      make.bottom.equalTo(safeAreaInsets.bottom).inset(16)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
    
    adView.nativeAd = ad
  }
  
  @objc private func handleCloseButtonClicked(sender: UIButton) {
    viewModel.handleCloseButtonClicked()
  }
  
}
