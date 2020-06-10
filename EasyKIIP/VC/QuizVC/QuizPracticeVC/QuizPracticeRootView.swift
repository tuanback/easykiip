//
//  QuizPracticeRootView.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/10.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import AVFoundation

class QuizPracticeRootView: NiblessView {
  
  private let stackViewContainer = UIStackView()
  private let labelQuestion = UILabel()
  private let stackViewOptionContainer = UIStackView()
  
  private let disposeBag = DisposeBag()
  
  private let viewModel: QuizPracticeViewModel
  
  private var player: AVAudioPlayer?
  
  init(viewModel: QuizPracticeViewModel,
       frame: CGRect = .zero) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    
    stackViewContainer.axis = .vertical
    stackViewContainer.alignment = .fill
    stackViewContainer.distribution = .fill
    stackViewContainer.spacing = 30
    
    addSubview(stackViewContainer)
    
    labelQuestion.layer.borderColor = UIColor.appRed.cgColor
    labelQuestion.layer.borderWidth = 3
    labelQuestion.layer.cornerRadius = 10
    labelQuestion.textColor = UIColor.appLabelBlack
    labelQuestion.font = UIFont.appFontDemiBold(ofSize: 25)
    labelQuestion.numberOfLines = 0
    labelQuestion.minimumScaleFactor = 0.3
    
    labelQuestion.layer.cornerRadius = 10
    labelQuestion.layer.borderWidth = 2
    labelQuestion.layer.borderColor = UIColor.appRed.cgColor
    
    stackViewOptionContainer.axis = .vertical
    stackViewOptionContainer.distribution = .fillEqually
    stackViewOptionContainer.alignment = .fill
    stackViewOptionContainer.spacing = 8
    
    stackViewContainer.addArrangedSubview(labelQuestion)
    stackViewContainer.addArrangedSubview(stackViewOptionContainer)
    
    stackViewContainer.snp.makeConstraints { (make) in
      make.top.equalToSuperview().inset(30)
      make.leading.equalToSuperview().inset(40)
      make.trailing.equalToSuperview().inset(40)
      make.bottom.equalToSuperview().inset(80)
    }
    
    stackViewOptionContainer.snp.makeConstraints { (make) in
      make.height.equalTo(0)
    }
    
    bindViewModel()
  }
  
  private func bindViewModel() {
    
    viewModel.oQuestion
      .drive(labelQuestion.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.oOption
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] options in
        guard let strongSelf = self else { return }
        
        strongSelf.stackViewOptionContainer.arrangedSubviews.forEach {
          $0.removeFromSuperview()
        }
        
        strongSelf.stackViewOptionContainer.snp.updateConstraints { (make) in
          if options.count > 0 {
            make.height.equalTo(options.count * 44 + (options.count - 1) * 8)
          }
          else {
            make.height.equalTo(0)
          }
        }
        
        for option in options {
          let button = strongSelf.createOptionButton(option: option.key, status: option.value)
          strongSelf.stackViewOptionContainer.addArrangedSubview(button)
        }
        
      })
      .disposed(by: disposeBag)
    
    viewModel.oPlaySound
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] sound in
        let url = sound.url
        self?.playSound(url: url)
      })
      .disposed(by: disposeBag)
    
    viewModel.oCorrectViewHidden
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] isHidden in
        // TODO: Show correct view
        
      })
      .disposed(by: disposeBag)
  }
  
  func playSound(url: URL) {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
      
      player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
      
      guard let player = player else { return }
      
      player.play()
      
    } catch let error {
      print(error.localizedDescription)
    }
  }
  
  private func createOptionButton(option: String, status: QuizOptionStatus) -> UIButton {
    
    let button = UIButton()
    button.setTitle(option, for: .normal)
    button.titleLabel?.font = UIFont.appFontRegular(ofSize: 20)
    button.titleLabel?.numberOfLines = 0
    button.titleLabel?.minimumScaleFactor = 0.2
    button.titleLabel?.adjustsFontSizeToFitWidth = true
    
    button.layer.cornerRadius = 10
    button.layer.borderWidth = 3
    
    button.setTitleColor(UIColor.white, for: .selected)
    button.setTitleColor(UIColor.appLabelBlack, for: .normal)
    button.setTitleColor(UIColor.appSecondaryBackground, for: .disabled)
    
    switch status {
    case .correct:
      button.isEnabled = true
      button.backgroundColor = UIColor.appRed
      button.layer.borderColor = UIColor.appRed.cgColor
    case .wrong:
      button.isEnabled = false
      button.backgroundColor = UIColor.appSecondaryBackground
      button.layer.borderColor = UIColor.appSecondaryBackground.cgColor
    case .notSelected:
      button.backgroundColor = UIColor.clear
      button.layer.borderColor = UIColor.appRed.cgColor
    }
    
    return button
  }
  
}
