//
//  QuizNewWordRootView.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/09.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class QuizNewWordRootView: NiblessView {
  
  private let buttonSpeak = UIButton()
  private let labelWord = UILabel()
  private let labelMeaning = UILabel()
  private let stackViewButtonContainer = UIStackView()
  private let buttonLearn = UIButton()
  private let buttonMaster = UIButton()
  
  private let disposeBag = DisposeBag()
  
  private let viewModel: QuizNewWordViewModel
  private var speechSynthesizer = SpeechSynthesizer()
  
  init(viewModel: QuizNewWordViewModel,
       frame: CGRect = .zero) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    
    addSubview(buttonSpeak)
    addSubview(labelWord)
    addSubview(labelMeaning)
    addSubview(stackViewButtonContainer)
    
    buttonSpeak.setImage(UIImage(named: IconName.speaker), for: .normal)
    buttonSpeak.addTarget(self, action: #selector(didSpeakButtonClicked(sender:)), for: .touchUpInside)
    
    labelWord.font = UIFont.appFontDemiBold(ofSize: 30)
    labelWord.numberOfLines = 0
    labelWord.textColor = UIColor.appLabelBlack
    labelWord.textAlignment = .center
    labelWord.minimumScaleFactor = 0.3
    
    labelMeaning.font = UIFont.appFontDemiBold(ofSize: 30)
    labelMeaning.numberOfLines = 0
    labelMeaning.textColor = UIColor.appLabelBlack
    labelMeaning.textAlignment = .center
    labelMeaning.minimumScaleFactor = 0.3
    
    stackViewButtonContainer.axis = .horizontal
    stackViewButtonContainer.alignment = .fill
    stackViewButtonContainer.distribution = .fillEqually
    stackViewButtonContainer.spacing = 32
    
    buttonLearn.backgroundColor = UIColor.appRed
    buttonLearn.setTitleColor(UIColor.white, for: .normal)
    buttonLearn.titleLabel?.font = UIFont.appFontMedium(ofSize: 18)
    buttonLearn.setTitle(Strings.learn, for: .normal)
    buttonLearn.addTarget(self, action: #selector(didLearnButtonClicked(sender:)), for: .touchUpInside)
    buttonLearn.layer.cornerRadius = 8
    
    buttonMaster.backgroundColor = UIColor.appSecondaryBackground
    buttonMaster.setTitleColor(UIColor.appRed, for: .normal)
    buttonMaster.titleLabel?.font = UIFont.appFontMedium(ofSize: 18)
    buttonMaster.setTitle(Strings.knew, for: .normal)
    buttonMaster.addTarget(self, action: #selector(didMasterButtonClicked(sender:)), for: .touchUpInside)
    buttonMaster.layer.cornerRadius = 8
    
    stackViewButtonContainer.addArrangedSubview(buttonMaster)
    stackViewButtonContainer.addArrangedSubview(buttonLearn)
    
    stackViewButtonContainer.snp.makeConstraints { (make) in
      make.width.equalToSuperview().multipliedBy(0.8)
      make.centerX.equalToSuperview()
      make.height.equalTo(50)
      make.bottom.equalToSuperview().inset(50)
    }
    
    labelWord.snp.makeConstraints { (make) in
      make.width.equalToSuperview().multipliedBy(0.8)
      make.centerY.equalToSuperview().offset(-120)
      make.centerX.equalToSuperview()
    }
    
    buttonSpeak.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(stackViewButtonContainer.snp.top).offset(-48)
    }
    
    labelMeaning.snp.makeConstraints { (make) in
      make.width.equalToSuperview().multipliedBy(0.8)
      make.centerX.equalToSuperview()
      make.top.equalTo(labelWord.snp.bottom).offset(16)
      make.bottom.lessThanOrEqualTo(buttonSpeak.snp.top).offset(-16)
    }
    
    bindViewModel()
  }
  
  private func bindViewModel() {
    viewModel.oWord
      .drive(labelWord.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.oMeaning
      .drive(labelMeaning.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.oSpeak
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] word in
        self?.speechSynthesizer.speak(word: word)
      })
    .disposed(by: disposeBag)
  }
  
  @objc private func didSpeakButtonClicked(sender: UIButton) {
    viewModel.handleViewDidAppear()
  }
  
  @objc private func didLearnButtonClicked(sender: UIButton) {
    viewModel.handleAnswer()
  }
  
  @objc private func didMasterButtonClicked(sender: UIButton) {
    viewModel.markAsMastered()
  }
  
}
