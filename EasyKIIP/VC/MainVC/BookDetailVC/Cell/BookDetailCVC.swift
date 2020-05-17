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
  
  private var viewProgressContainer: UIView!
  
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
  }
  
  private func setupViews() {
    
    backgroundColor = UIColor.appBackground
    layer.shadowColor = UIColor.appShadowColor.cgColor
    layer.shadowOpacity = 0.25
    layer.shadowRadius = 3
    layer.shadowOffset = CGSize(width: 0, height: 0)
    layer.cornerRadius = 10
    
    viewUnitIndicatorContainer = UIView()
    viewUnitIndicatorContainer.backgroundColor = UIColor.appRed
    viewUnitIndicatorContainer.layer.cornerRadius = 8
    
    addSubview(viewUnitIndicatorContainer)
    
    labelUnitIndicator = UILabel()
    labelUnitIndicator.font = UIFont.appFontDemiBold(ofSize: 25)
    labelUnitIndicator.textColor = UIColor.white
    
    viewUnitIndicatorContainer.addSubview(labelUnitIndicator)
    
    labelLessonKorean = UILabel()
    labelLessonKorean.numberOfLines = 2
    labelLessonKorean.font = UIFont.appFontRegular(ofSize: 16)
    labelLessonKorean.textColor = UIColor.appLabelBlack
    labelLessonKorean.textAlignment = .left
    labelLessonKorean.adjustsFontSizeToFitWidth = true
    labelLessonKorean.minimumScaleFactor = 0.5
    
    labelLessonTranslation = UILabel()
    labelLessonTranslation.numberOfLines = 2
    labelLessonTranslation.font = UIFont.appFontRegular(ofSize: 14)
    labelLessonTranslation.textColor = UIColor.appSecondaryLabel
    labelLessonTranslation.textAlignment = .left
    labelLessonTranslation.adjustsFontSizeToFitWidth = true
    labelLessonTranslation.minimumScaleFactor = 0.5
    
    labelLastPracticed = UILabel()
    labelLastPracticed.font = UIFont.appFontRegular(ofSize: 12)
    labelLastPracticed.textColor = UIColor.appSecondaryLabel
    
    let lessonNameContainer = UIStackView(arrangedSubviews: [labelLessonKorean,
                                                             labelLessonTranslation])
    lessonNameContainer.alignment = .fill
    lessonNameContainer.axis = .vertical
    lessonNameContainer.distribution = .fillEqually
    lessonNameContainer.spacing = 8
    
    let lastPracticeContainer = UIStackView(arrangedSubviews: [labelLastPracticed])
    
    let labelContainer = UIStackView(arrangedSubviews: [lessonNameContainer,
                                                        lastPracticeContainer])
    labelContainer.axis = .horizontal
    labelContainer.alignment = .fill
    labelContainer.distribution = .fill
    labelContainer.spacing = 8
    
    viewProgressContainer = UIView()
    viewProgressContainer.backgroundColor = UIColor.appRed
    
    let rightStackview = UIStackView(arrangedSubviews: [labelContainer,
                                                        viewProgressContainer])
    rightStackview.axis = .vertical
    rightStackview.spacing = 8
    rightStackview.alignment = .fill
    rightStackview.distribution = .fill
    
    let containerStackView = UIStackView(arrangedSubviews: [viewUnitIndicatorContainer,
                                                            rightStackview])
    containerStackView.axis = .horizontal
    containerStackView.spacing = 8
    containerStackView.alignment = .fill
    containerStackView.distribution = .fill
    
    addSubview(containerStackView)
    
    // Set constraint here
    viewUnitIndicatorContainer.snp.makeConstraints { (make) in
      make.width.equalTo(viewUnitIndicatorContainer.snp.height).multipliedBy(0.9)
    }
    
    labelUnitIndicator.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
    }
    
    viewProgressContainer.snp.makeConstraints { (make) in
      make.height.equalTo(20)
    }
    
    lastPracticeContainer.snp.makeConstraints { (make) in
      make.width.equalTo(40)
    }
    
    containerStackView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview().inset(10)
      
    }
  }
  
}
