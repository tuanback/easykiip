//
//  GrammarDetailRootView.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/07/12.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class GrammarDetailRootView: NiblessView {
  
  private let stackViewContainer: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = 10
    return stackView
  }()
  
  private var labelName = UILabel()
  private var labelSimilarGrammarTitle = UILabel()
  private var labelSimilarGrammar = UILabel()
  private var labelExplainationTitle = UILabel()
  private var labelExplaination = UILabel()
  private var labelExampleTitle = UILabel()
  private var labelExample = UILabel()
  
  private let disposeBag = DisposeBag()
  
  private let viewModel: GrammarDetailViewModel
  
  init(frame: CGRect = .zero,
       viewModel: GrammarDetailViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    
    backgroundColor = UIColor.appBackground
    
    addSubview(stackViewContainer)
    
    labelName.textColor = UIColor.appRed
    labelName.font = UIFont.appFontBold(ofSize: 30)
    labelName.minimumScaleFactor = 0.5
    labelName.adjustsFontSizeToFitWidth = true
    labelName.numberOfLines = 0
    
    labelSimilarGrammarTitle.textColor = UIColor.appRed
    labelSimilarGrammarTitle.font = UIFont.appFontDemiBold(ofSize: 22)
    
    labelSimilarGrammar.textColor = UIColor.appLabelBlack
    labelSimilarGrammar.font = UIFont.appFontDemiBold(ofSize: 20)
    labelSimilarGrammar.minimumScaleFactor = 0.5
    labelSimilarGrammar.adjustsFontSizeToFitWidth = true
    
    labelExplainationTitle.textColor = UIColor.appRed
    labelExplainationTitle.font = UIFont.appFontDemiBold(ofSize: 22)
    labelExplainationTitle.text = Strings.usage
    
    labelExplaination.textColor = UIColor.appLabelBlack
    labelExplaination.font = UIFont.appFontRegular(ofSize: 20)
    labelExplaination.minimumScaleFactor = 0.5
    labelExplaination.adjustsFontSizeToFitWidth = true
    labelExplaination.numberOfLines = 0
    
    labelExampleTitle.textColor = UIColor.appRed
    labelExampleTitle.font = UIFont.appFontDemiBold(ofSize: 22)
    labelExampleTitle.text = Strings.example
    
    labelExample.textColor = UIColor.appLabelBlack
    labelExample.font = UIFont.appFontRegular(ofSize: 20)
    labelExample.minimumScaleFactor = 0.5
    labelExample.adjustsFontSizeToFitWidth = true
    labelExample.numberOfLines = 0
    
    stackViewContainer.addArrangedSubview(labelName)
    stackViewContainer.addArrangedSubview(labelSimilarGrammarTitle)
    stackViewContainer.addArrangedSubview(labelSimilarGrammar)
    stackViewContainer.addArrangedSubview(labelExplainationTitle)
    stackViewContainer.addArrangedSubview(labelExplaination)
    stackViewContainer.addArrangedSubview(labelExampleTitle)
    stackViewContainer.addArrangedSubview(labelExample)
    stackViewContainer.addArrangedSubview(UIView())
    
    stackViewContainer.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(32)
      make.trailing.equalToSuperview().inset(32)
      make.top.equalTo(safeAreaLayoutGuide).inset(16)
      make.bottom.equalTo(safeAreaLayoutGuide).inset(8)
    }
    
    viewModel.oName
      .drive(labelName.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.oSimilarTitle
      .drive(labelSimilarGrammarTitle.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.oSimilarGrammar
      .drive(labelSimilarGrammar.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.oExplaination
      .drive(labelExplaination.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.oExample
      .drive(labelExample.rx.text)
      .disposed(by: disposeBag)
  }
}
