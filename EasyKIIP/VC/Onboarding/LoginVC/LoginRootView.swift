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
import AuthenticationServices
import CryptoKit

class LoginRootView: NiblessView {
  
  private let viewModel: LoginViewModel
  
  private lazy var svButtonContainer = UIStackView()
  private lazy var googleSignInButton = GIDSignInButton()
  private lazy var kakaoSignInButton = KOLoginButton()
  private lazy var faceBookLoginButton = FBLoginButton()
  @available(iOS 13.0, *)
  private lazy var siwaButton = ASAuthorizationAppleIDButton()
  
  private var labelLogo = UILabel()
  private let buttonClose = UIButton()
  
  private var currentNonce: String?
  
  init(frame: CGRect = .zero,
       viewModel: LoginViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    
    labelLogo.text = Strings.logIn
    labelLogo.font = UIFont.appFontDemiBold(ofSize: 40)
    labelLogo.textColor = UIColor.white
    
    buttonClose.setImage(UIImage(named: IconName.closeWhite), for: .normal)
    buttonClose.addTarget(self, action: #selector(handleCloseButtonClicked(sender:)), for: .touchUpInside)
    buttonClose.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    backgroundColor = UIColor.appRed
    
    googleSignInButton.style = .wide
    kakaoSignInButton.addTarget(self, action: #selector(handleKakaoLoginButtonClicked(sender:)), for: .touchUpInside)
    
    faceBookLoginButton.delegate = self
    
    svButtonContainer.axis = .vertical
    svButtonContainer.alignment = .fill
    svButtonContainer.distribution = .fillEqually
    svButtonContainer.spacing = 16
    
    addSubview(labelLogo)
    addSubview(buttonClose)
    addSubview(svButtonContainer)
    
    svButtonContainer.addArrangedSubview(googleSignInButton)
    svButtonContainer.addArrangedSubview(faceBookLoginButton)
    //svButtonContainer.addArrangedSubview(kakaoSignInButton)
    if #available(iOS 13.0, *) {
      svButtonContainer.addArrangedSubview(siwaButton)
      siwaButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchDown)
    } else {
      // Fallback on earlier versions
    }
    
    buttonClose.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(16)
      make.top.equalTo(safeAreaInsets.top).offset(44)
      make.size.equalTo(40)
    }
    
    labelLogo.snp.makeConstraints { (make) in
      make.centerX.equalTo(self)
      make.top.equalTo(buttonClose.snp.bottom).offset(16)
    }
    
    svButtonContainer.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      if #available(iOS 13.0, *) {
        make.height.equalTo(182)
      } else {
        make.height.equalTo(116)
      }
      make.width.equalTo(self).multipliedBy(0.8)
    }
  }
  
  @objc private func handleCloseButtonClicked(sender: UIButton) {
    viewModel.handleCloseButtonClicked()
  }
  
  @objc private func handleKakaoLoginButtonClicked(sender: UIButton) {
    viewModel.kakaoLogin()
  }
  
  @objc func appleSignInTapped() {
    if #available(iOS 13.0, *) {
      appleLogin()
    }
  }
  
  @available(iOS 13.0, *)
  private func appleLogin() {
    let nonce = randomNonceString()
    currentNonce = nonce
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce)

    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }
  
  @available(iOS 13, *)
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      return String(format: "%02x", $0)
    }.joined()

    return hashString
  }
  
  // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }

      randoms.forEach { random in
        if remainingLength == 0 {
          return
        }

        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }

    return result
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
    print("loginButtonDidLogOut")
  }
  
  private func getFBUserData(){
    guard let accessToken = AccessToken.current else { return }
    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
    viewModel.login(with: credential, provider: .facebook)
  }
  
}

extension LoginRootView: ASAuthorizationControllerPresentationContextProviding {
  @available(iOS 13.0, *)
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.window!
  }
}

@available(iOS 13.0, *)
extension LoginRootView: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential.
      let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)
      viewModel.login(with: credential, provider: .apple)
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}
