//
//  LoginRootView.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Firebase
import GoogleSignIn

class LoginRootView: NiblessView {
  
  private let viewModel: LoginViewModel
  
  private var googleSignInButton: GIDSignInButton!
  private let buttonClose = UIButton()
  
  init(frame: CGRect = .zero,
       viewModel: LoginViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    
    buttonClose.setImage(UIImage(named: IconName.close), for: .normal)
    buttonClose.addTarget(self, action: #selector(handleCloseButtonClicked(sender:)), for: .touchUpInside)
    
    backgroundColor = UIColor.appBackground
    
    googleSignInButton = GIDSignInButton()
    googleSignInButton.style = .wide
    
    addSubview(buttonClose)
    addSubview(googleSignInButton)
    
    buttonClose.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(16)
      make.top.equalTo(safeAreaInsets.top).inset(32)
      make.size.equalTo(44)
    }
    
    googleSignInButton.snp.makeConstraints { (make) in
      make.centerX.equalTo(self)
      make.bottom.equalTo(self).offset(-80)
      make.height.equalTo(60)
      make.width.equalTo(self).multipliedBy(0.8)
    }
  }
  
  @objc private func handleCloseButtonClicked(sender: UIButton) {
    viewModel.handleCloseButtonClicked()
  }
  
}
