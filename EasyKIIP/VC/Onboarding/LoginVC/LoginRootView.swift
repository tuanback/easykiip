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
import KakaoOpenSDK
import FBSDKLoginKit

class LoginRootView: NiblessView {
  
  private let viewModel: LoginViewModel
  
  private var svButtonContainer = UIStackView()
  private var googleSignInButton = GIDSignInButton()
  private var kakaoSignInButton = KOLoginButton()
  private var faceBookLoginButton = FBLoginButton()
  
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
    
    googleSignInButton.style = .wide
    kakaoSignInButton.addTarget(self, action: #selector(handleKakaoLoginButtonClicked(sender:)), for: .touchUpInside)
    
    faceBookLoginButton.delegate = self
    
    svButtonContainer.axis = .vertical
    svButtonContainer.alignment = .fill
    svButtonContainer.distribution = .fillEqually
    svButtonContainer.spacing = 16
    
    addSubview(buttonClose)
    addSubview(svButtonContainer)
    
    svButtonContainer.addArrangedSubview(kakaoSignInButton)
    svButtonContainer.addArrangedSubview(googleSignInButton)
    svButtonContainer.addArrangedSubview(faceBookLoginButton)
    
    buttonClose.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(16)
      make.top.equalTo(safeAreaInsets.top).inset(32)
      make.size.equalTo(44)
    }
    
    svButtonContainer.snp.makeConstraints { (make) in
      make.centerX.equalTo(self)
      make.bottom.equalTo(self).offset(-80)
      make.height.equalTo(164)
      make.width.equalTo(self).multipliedBy(0.8)
    }
  }
  
  @objc private func handleCloseButtonClicked(sender: UIButton) {
    viewModel.handleCloseButtonClicked()
  }
  
  @objc private func handleKakaoLoginButtonClicked(sender: UIButton) {
    viewModel.kakaoLogin()
  }
  
}

extension LoginRootView: LoginButtonDelegate {
  
  func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
    guard let loginResult = result else {
      return
    }
    print(loginResult.grantedPermissions)
    getFBUserData()
  }
  
  func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    
  }
  
  private func getFBUserData(){
    guard let accessToken = AccessToken.current else { return }
    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
    viewModel.login(with: credential, provider: .facebook)
  }
  
}
