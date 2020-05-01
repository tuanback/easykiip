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
  
  init(frame: CGRect = .zero,
       viewModel: LoginViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    backgroundColor = UIColor.appBackground
    
    googleSignInButton = GIDSignInButton()
    
    addSubview(googleSignInButton)
    
    googleSignInButton.snp.makeConstraints { (make) in
      make.centerX.equalTo(self)
      make.bottom.equalTo(self).offset(-80)
      make.height.equalTo(60)
      make.width.equalTo(self).multipliedBy(0.8)
    }
  }
  
  
  
}
