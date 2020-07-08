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

class QuizPracticeRootView: NiblessView {
  
  private let stackViewContainer = UIStackView()
  private let labelQuestion = UILabel()
  private let stackViewOptionContainer = UIStackView()
  
  private let disposeBag = DisposeBag()
  
  private let viewModel: QuizPracticeViewModel
  
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
    
    let viewQuestionContainer = UIView()
    viewQuestionContainer.layer.cornerRadius = 10
    viewQuestionContainer.layer.borderWidth = 2
    viewQuestionContainer.layer.borderColor = UIColor.appRed.cgColor
    
    labelQuestion.textColor = UIColor.appLabelBlack
    labelQuestion.font = UIFont.appFontDemiBold(ofSize: 25)
    labelQuestion.numberOfLines = 0
    labelQuestion.minimumScaleFactor = 0.3
    labelQuestion.textAlignment = .center
    
    viewQuestionContainer.addSubview(labelQuestion)
    
    stackViewOptionContainer.axis = .vertical
    stackViewOptionContainer.distribution = .fillEqually
    stackViewOptionContainer.alignment = .fill
    stackViewOptionContainer.spacing = 8
    
    stackViewContainer.addArrangedSubview(viewQuestionContainer)
    stackViewContainer.addArrangedSubview(stackViewOptionContainer)
    
    labelQuestion.snp.makeConstraints { (make) in
      make.edges.equalToSuperview().inset(8)
    }
    
    stackViewContainer.snp.makeConstraints { (make) in
      make.top.equalToSuperview().inset(20)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
      make.bottom.equalTo(safeAreaInsets.bottom).inset(20)
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
            make.height.equalTo(options.count * 80 + (options.count - 1) * 8)
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
    
    viewModel.oCorrectViewHidden
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] isHidden in
        // TODO: Show correct view
        
      })
      .disposed(by: disposeBag)
  }
  
  private func createOptionButton(option: String, status: QuizOptionStatus) -> UIButton {
    
    let button = UIButton()
    button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    button.setTitle(option, for: .normal)
    button.titleLabel?.font = UIFont.appFontRegular(ofSize: 15)
    button.titleLabel?.numberOfLines = 0
    button.titleLabel?.minimumScaleFactor = 0.2
    button.titleLabel?.adjustsFontSizeToFitWidth = true
    button.titleLabel?.textAlignment = .center
    
    button.layer.cornerRadius = 10
    button.layer.borderWidth = 2
    
    button.setTitleColor(UIColor.white, for: .selected)
    button.setTitleColor(UIColor.appLabelBlack, for: .normal)
    button.setTitleColor(UIColor.appSystemGray3, for: .disabled)
    
    switch status {
    case .correct:
      button.isEnabled = true
      button.backgroundColor = UIColor.appRed
      button.layer.borderColor = UIColor.appRed.cgColor
      button.isSelected = true
    case .wrong:
      button.isEnabled = false
      button.layer.borderColor = UIColor.appSystemGray3.cgColor
    case .notSelected:
      button.backgroundColor = UIColor.clear
      button.layer.borderColor = UIColor.appRed.cgColor
    }
  
    button.addTarget(self, action: #selector(handleOptionButtonClicked(sender:)), for: .touchUpInside)
    
    return button
  }
  
  @objc private func handleOptionButtonClicked(sender: UIButton) {
    guard let answer = sender.titleLabel?.text else { return }
    viewModel.handleAnswer(answer:  answer)
  }
}
