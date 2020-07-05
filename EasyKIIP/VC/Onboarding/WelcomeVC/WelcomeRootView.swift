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
  private var labelLoginLater: UILabel!
  private var buttonLogin: UIButton!
  private var buttonPlayAsGuest: UIButton!
  
  init(frame: CGRect = .zero, viewModel: WelcomeViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    styleView()
    setupViews()
  }
  
  private func styleView() {
    backgroundColor = UIColor.appRed
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
    buttonLogin.titleLabel?.font = UIFont.appFontDemiBold(ofSize: 20)
    buttonLogin.setTitle(Strings.login, for: .normal)
    buttonLogin.setTitleColor(UIColor.appRed, for: .normal)
    buttonLogin.backgroundColor = UIColor.white
    buttonLogin.layer.cornerRadius = 8
    buttonLogin.layer.masksToBounds = true
    
    buttonLogin.rx.action = viewModel.loginAction
    
    labelLoginLater = UILabel()
    labelLoginLater.text = Strings.loginLater
    labelLoginLater.textColor = UIColor(hexString: "F0F0F0")
    labelLoginLater.font = UIFont.appFontRegular(ofSize: 22)
    
    buttonPlayAsGuest = UIButton()
    buttonPlayAsGuest.titleLabel?.font = UIFont.appFontDemiBold(ofSize: 22)
    buttonPlayAsGuest.setTitle(Strings.playAsGuest, for: .normal)
    buttonPlayAsGuest.backgroundColor = UIColor.clear
    buttonPlayAsGuest.setTitleColor(UIColor.white, for: .normal)
    
    buttonPlayAsGuest.rx.action = viewModel.signedInLaterAction
    
    addSubview(labelLogo)
    addSubview(labelTitle)
    addSubview(labelMessage)
    addSubview(buttonLogin)
    
    let stackView = UIStackView(arrangedSubviews: [labelLoginLater,
                                                   buttonPlayAsGuest])
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = 8
    
    addSubview(stackView)
    
    labelLogo.snp.makeConstraints { (make) in
      make.centerX.equalTo(self)
      make.top.equalTo(safeAreaInsets.top).offset(80)
    }
    
    labelTitle.snp.makeConstraints { (make) in
      make.leading.equalTo(self).offset(20)
      make.trailing.equalTo(self).offset(-20)
      make.centerY.equalTo(self).offset(-50)
    }
    
    stackView.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(safeAreaInsets.bottom).offset(-60)
      make.height.equalTo(40)
    }
    
    buttonLogin.snp.makeConstraints { (make) in
      make.centerX.equalTo(self)
      make.bottom.equalTo(buttonPlayAsGuest.snp.top).offset(-20)
      make.width.equalTo(self).multipliedBy(0.8)
      make.height.equalTo(50)
    }
    
    labelMessage.snp.makeConstraints { (make) in
      make.top.equalTo(labelTitle.snp.bottom).offset(8)
      make.leading.equalTo(self).offset(20)
      make.trailing.equalTo(self).offset(-20)
    }
  }
  
}
