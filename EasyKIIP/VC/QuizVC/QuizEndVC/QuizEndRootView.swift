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
  private let buttonUpgradeToPremium1 = UIButton()
  private let buttonUpgradeToPremium2 = UIButton()
  
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
    
    buttonUpgradeToPremium1.backgroundColor = UIColor.appRed
    buttonUpgradeToPremium1.setTitle(Strings.upgradeToPremium, for: .normal)
    buttonUpgradeToPremium1.setTitleColor(UIColor.white, for: .normal)
    buttonUpgradeToPremium1.layer.cornerRadius = 10
    buttonUpgradeToPremium1.titleLabel?.font = UIFont.appFontMedium(ofSize: 16)
    
    buttonUpgradeToPremium1.addTarget(self, action: #selector(handleUpgradeToPremiumButtonClicked(sender:)), for: .touchUpInside)
    
    viewEndQuiz.addSubview(labelEndQuizText)
    viewEndQuiz.addSubview(buttonContinue)
    if !viewModel.isPremiumUser() {
      viewEndQuiz.addSubview(buttonUpgradeToPremium1)
    }
    
    viewEndQuiz.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    viewAdContainer.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    if !viewModel.isPremiumUser() {
      buttonUpgradeToPremium1.snp.makeConstraints { (make) in
        make.bottom.equalTo(safeAreaLayoutGuide).inset(32)
        make.height.equalTo(60)
        make.leading.equalToSuperview().inset(32)
        make.trailing.equalToSuperview().inset(32)
      }
      
      buttonContinue.snp.makeConstraints { (make) in
        make.bottom.equalTo(buttonUpgradeToPremium1.snp.top).offset(-16)
        make.height.equalTo(60)
        make.leading.equalToSuperview().inset(32)
        make.trailing.equalToSuperview().inset(32)
      }
    }
    else {
      buttonContinue.snp.makeConstraints { (make) in
        make.bottom.equalTo(safeAreaLayoutGuide).inset(32)
        make.height.equalTo(60)
        make.leading.equalToSuperview().inset(32)
        make.trailing.equalToSuperview().inset(32)
      }
    }
    
    labelEndQuizText.snp.makeConstraints { (make) in
      make.top.equalTo(safeAreaLayoutGuide).inset(32)
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
    
    buttonUpgradeToPremium2.backgroundColor = UIColor.appRed
    buttonUpgradeToPremium2.setTitle(Strings.upgradeToPremium, for: .normal)
    buttonUpgradeToPremium2.setTitleColor(UIColor.white, for: .normal)
    buttonUpgradeToPremium2.layer.cornerRadius = 8
    buttonUpgradeToPremium2.titleLabel?.font = UIFont.appFontMedium(ofSize: 16)
    
    buttonUpgradeToPremium2.addTarget(self, action: #selector(handleUpgradeToPremiumButtonClicked(sender:)), for: .touchUpInside)
    
    let viewSeparator = UIView()
    viewSeparator.backgroundColor = UIColor.appSystemGray3
    
    let viewBottomSeparator = UIView()
    viewBottomSeparator.backgroundColor = UIColor.appSystemGray3
    
    viewAdContainer.addSubview(buttonClose)
    viewAdContainer.addSubview(labelAdExplaination)
    viewAdContainer.addSubview(viewSeparator)
    viewAdContainer.addSubview(adView)
    if !viewModel.isPremiumUser() {
      viewAdContainer.addSubview(viewBottomSeparator)
      viewAdContainer.addSubview(buttonUpgradeToPremium2)
    }
    
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
    
    if !viewModel.isPremiumUser() {
      buttonUpgradeToPremium2.snp.makeConstraints { (make) in
        make.bottom.equalTo(safeAreaLayoutGuide).inset(32)
        make.height.equalTo(60)
        make.leading.equalToSuperview().inset(16)
        make.trailing.equalToSuperview().inset(16)
      }
      
      viewBottomSeparator.snp.makeConstraints { (make) in
        make.height.equalTo(0.5)
        make.bottom.equalTo(buttonUpgradeToPremium2.snp.top).offset(-16)
        make.leading.equalToSuperview()
        make.trailing.equalToSuperview()
      }
      
      adView.snp.makeConstraints { (make) in
        make.top.equalTo(viewSeparator.snp.bottom).offset(16)
        make.bottom.equalTo(viewBottomSeparator.snp.top).offset(-6)
        make.leading.equalToSuperview().inset(16)
        make.trailing.equalToSuperview().inset(16)
      }
    }
    else {
      adView.snp.makeConstraints { (make) in
        make.top.equalTo(viewSeparator.snp.bottom).offset(16)
        make.bottom.equalTo(safeAreaLayoutGuide).inset(16)
        make.leading.equalToSuperview().inset(16)
        make.trailing.equalToSuperview().inset(16)
      }
    }
    
    adView.nativeAd = ad
  }
  
  @objc private func handleCloseButtonClicked(sender: UIButton) {
    viewModel.handleCloseButtonClicked()
  }
  
  @objc private func handleUpgradeToPremiumButtonClicked(sender: UIButton) {
    viewModel.handleUpgradeToPremiumButtonClicked()
  }
  
}
