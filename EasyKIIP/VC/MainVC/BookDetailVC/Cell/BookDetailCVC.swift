//
//  BookDetailCVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit

class BookDetailCVC: UICollectionViewCell {
  
  private var viewUnitIndicatorContainer: UIView!
  private var labelUnitIndicator: UILabel!
  
  private var labelLessonKorean: UILabel!
  private var labelLessonTranslation: UILabel!
  private var labelLastPracticed: UILabel!
  
  private var viewProgressContainer: ProgressBar!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configCell(viewModel: LessonItemViewModel) {
    
    labelUnitIndicator.text = "\(viewModel.lessonIndex)"
    labelLessonKorean.text = viewModel.name
    labelLessonTranslation.text = viewModel.translation
    if let lastTimeLearnedFromToday = viewModel.lastTimeLearnedFromToday {
      if lastTimeLearnedFromToday == 0 {
        labelLastPracticed.text = Strings.today
      }
      else if lastTimeLearnedFromToday == 1 {
        labelLastPracticed.text = Strings.yesterday
      }
      else {
        labelLastPracticed.text = "\(lastTimeLearnedFromToday) " + Strings.daysAgo
      }
    }
    else {
      labelLastPracticed.text = ""
    }
    
    viewProgressContainer.isHidden = (viewModel.lastTimeLearnedFromToday == nil)
    viewProgressContainer.progress = viewModel.proficiency
  }
  
  private func setupViews() {
    
    backgroundColor = UIColor.appBackground
    layer.shadowColor = UIColor.appShadowColor.cgColor
    layer.shadowOpacity = 0.25
    layer.shadowRadius = 3
    layer.shadowOffset = CGSize(width: 0, height: 0)
    layer.cornerRadius = 10
    
    let containerView = UIView()
    containerView.backgroundColor = UIColor.clear
    
    viewUnitIndicatorContainer = UIView()
    viewUnitIndicatorContainer.backgroundColor = UIColor.appRed
    viewUnitIndicatorContainer.layer.cornerRadius = 8
    
    addSubview(containerView)
    
    containerView.addSubview(viewUnitIndicatorContainer)
    
    labelUnitIndicator = UILabel()
    labelUnitIndicator.font = UIFont.appFontDemiBold(ofSize: 25)
    labelUnitIndicator.textColor = UIColor.white
    
    viewUnitIndicatorContainer.addSubview(labelUnitIndicator)
    
    labelLessonKorean = UILabel()
    labelLessonKorean.numberOfLines = 0
    labelLessonKorean.font = UIFont.appFontRegular(ofSize: 20)
    labelLessonKorean.textColor = UIColor.appLabelBlack
    labelLessonKorean.textAlignment = .left
    labelLessonKorean.adjustsFontSizeToFitWidth = true
    labelLessonKorean.minimumScaleFactor = 0.5
    
    labelLessonTranslation = UILabel()
    labelLessonTranslation.numberOfLines = 0
    labelLessonTranslation.font = UIFont.appFontRegular(ofSize: 16)
    labelLessonTranslation.textColor = UIColor.appSecondaryLabel
    labelLessonTranslation.textAlignment = .left
    labelLessonTranslation.adjustsFontSizeToFitWidth = true
    labelLessonTranslation.minimumScaleFactor = 0.5
    
    labelLastPracticed = UILabel()
    labelLastPracticed.font = UIFont.appFontRegular(ofSize: 12)
    labelLastPracticed.textColor = UIColor.appSecondaryLabel
    labelLastPracticed.adjustsFontSizeToFitWidth = true
    labelLastPracticed.minimumScaleFactor = 0.3
    
    labelLastPracticed.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    labelLastPracticed.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    
    labelLessonKorean.setContentHuggingPriority(.defaultLow, for: .horizontal)
    labelLessonKorean.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    
    let lessonNameContainer = UIStackView(arrangedSubviews: [labelLessonKorean, labelLastPracticed])
    lessonNameContainer.alignment = .fill
    lessonNameContainer.axis = .horizontal
    lessonNameContainer.distribution = .fill
    lessonNameContainer.spacing = 4
    
    let labelContainer = UIStackView(arrangedSubviews: [lessonNameContainer, labelLessonTranslation, UIView()])
    labelContainer.axis = .vertical
    labelContainer.alignment = .fill
    labelContainer.distribution = .fill
    labelContainer.spacing = 8
    
    viewProgressContainer = ProgressBar()
    
    let rightStackview = UIStackView(arrangedSubviews: [labelContainer, viewProgressContainer])
    rightStackview.axis = .vertical
    rightStackview.spacing = 8
    rightStackview.alignment = .fill
    rightStackview.distribution = .fill
    
    let containerStackView = UIStackView(arrangedSubviews: [containerView, rightStackview])
    containerStackView.axis = .horizontal
    containerStackView.spacing = 8
    containerStackView.alignment = .fill
    containerStackView.distribution = .fill
    
    addSubview(containerStackView)
    
    // Set constraint here
    containerView.snp.makeConstraints { (make) in
      make.width.equalTo(120)
    }
    
    viewUnitIndicatorContainer.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    labelUnitIndicator.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
    }
    
    viewProgressContainer.snp.makeConstraints { (make) in
      make.height.equalTo(20)
    }
    
    containerStackView.snp.makeConstraints { (make) in
      make.top.equalToSuperview().inset(15)
      make.bottom.equalToSuperview().inset(10)
      make.leading.equalToSuperview().inset(10)
      make.trailing.equalToSuperview().inset(10)
    }
  }
  
}
