//
//  OnboardingView.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class OnboardingRootView: NiblessView {
  
  private var labelLogo: UILabel!
  private var labelTitle: UILabel!
  private var labelMessage: UILabel!
  private var buttonLogin: UIButton!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    styleView()
    setupViews()
  }
  
  private func styleView() {
    backgroundColor = UIColor.primaryColor
  }
  
  private func setupViews() {
    
    labelLogo = UILabel()
    labelLogo.text = Strings.logo
    
    labelTitle = UILabel()
    labelTitle.text = Strings.onboardingTitle
    labelTitle.textAlignment = .center
    
    labelMessage = UILabel()
    labelMessage.text = Strings.onboardingMessage
    labelMessage.numberOfLines = 0
    labelMessage.textAlignment = .center
    
    buttonLogin = UIButton()
    buttonLogin.setTitle(Strings.login, for: .normal)
    
    addSubview(labelLogo)
    addSubview(labelTitle)
    addSubview(labelMessage)
    addSubview(buttonLogin)
    
    labelLogo.snp.makeConstraints { (make) in
      make.centerX.equalTo(self)
      make.top.equalTo(self).offset(60)
    }
    
    labelTitle.snp.makeConstraints { (make) in
      make.leading.equalTo(self).offset(20)
      make.trailing.equalTo(self).offset(-20)
      make.centerY.equalTo(self).offset(-100)
    }
    
    labelMessage.snp.makeConstraints { (make) in
      make.top.equalTo(labelTitle.snp.bottom).offset(60)
      make.leading.equalTo(self).offset(20)
      make.trailing.equalTo(self).offset(-20)
    }
    
    buttonLogin.snp.makeConstraints { (make) in
      make.centerX.equalTo(self)
      make.bottom.equalTo(self).offset(-60)
      make.width.equalTo(self).multipliedBy(0.8)
      make.height.equalTo(60)
    }
  }
  
}
