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
import Action

class WelcomeRootView: NiblessView {
  
  private var viewModel: WelcomeViewModel
  
  private var labelLogo: UILabel!
  private var labelTitle: UILabel!
  private var labelMessage: UILabel!
  private var buttonLogin: UIButton!
  
  init(frame: CGRect = .zero, viewModel: WelcomeViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    styleView()
    setupViews()
  }
  
  private func styleView() {
    backgroundColor = UIColor.appPrimaryColor
  }
  
  private func setupViews() {
    
    labelLogo = UILabel()
    labelLogo.text = Strings.logo
    labelLogo.font = UIFont.appFontDemiBold(ofSize: 40)
    labelLogo.textColor = UIColor.white
    
    labelTitle = UILabel()
    labelTitle.text = Strings.onboardingTitle
    labelTitle.textAlignment = .center
    labelTitle.font = UIFont.appFontDemiBold(ofSize: 25)
    labelTitle.textColor = UIColor.white
    labelTitle.minimumScaleFactor = 0.5
    labelTitle.adjustsFontSizeToFitWidth = true
    
    labelMessage = UILabel()
    labelMessage.text = Strings.onboardingMessage
    labelMessage.numberOfLines = 0
    labelMessage.textAlignment = .center
    labelMessage.font = UIFont.appFontMedium(ofSize: 18)
    labelMessage.textColor = UIColor.white
    labelMessage.minimumScaleFactor = 0.5
    labelMessage.adjustsFontSizeToFitWidth = true
    
    buttonLogin = UIButton()
    buttonLogin.titleLabel?.font = UIFont.appFontMedium(ofSize: 20)
    buttonLogin.setTitle(Strings.login, for: .normal)
    buttonLogin.backgroundColor = UIColor.white
    buttonLogin.layer.cornerRadius = 8
    buttonLogin.layer.masksToBounds = true
    buttonLogin.setTitleColor(UIColor.black, for: .normal)
    
    buttonLogin.rx.action = viewModel.loginAction
    
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
      make.centerY.equalTo(self).offset(-50)
    }
    
    buttonLogin.snp.makeConstraints { (make) in
      make.centerX.equalTo(self)
      make.bottom.equalTo(self).offset(-60)
      make.width.equalTo(self).multipliedBy(0.8)
      make.height.equalTo(50)
    }
    
    labelMessage.snp.makeConstraints { (make) in
      make.bottom.equalTo(buttonLogin.snp.top).offset(-20)
      make.leading.equalTo(self).offset(20)
      make.trailing.equalTo(self).offset(-20)
    }
  }
  
}
