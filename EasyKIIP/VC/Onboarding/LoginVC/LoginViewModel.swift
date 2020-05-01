//
//  LoginViewModel.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UserSession
import RxSwift
import RxCocoa
import Firebase
import GoogleSignIn

public class LoginViewModel {
  
  private let userSessionRepository: UserSessionRepository
  private let signedInResponder: SignedInResponder
  
  var textInput = PublishRelay<String>()
  var errorMessage = PublishRelay<String>()
  
  private var authState: AuthState?
  private let disposeBag = DisposeBag()
  
  init(userSessionRepository: UserSessionRepository,
       signedInResponder: SignedInResponder) {
    self.userSessionRepository = userSessionRepository
    self.signedInResponder = signedInResponder
  }
  
  func googleLogin(with credential: AuthCredential) {
    let observerble = userSessionRepository.signIn(with: credential, provider: .google)
    
    observerble
      .subscribe(
        onNext: { [weak self] state in
        self?.authState = state
        switch state {
        case .waitingForDisplayName(let displayName):
          self?.textInput.accept("Select factor to sign in\n\(displayName)")
        case .waitingForVerificationCode(let displayName):
          self?.textInput.accept("Verification code for \(displayName)")
        case .success(_):
          self?.signedInResponder.signedIn()
        default:
          break
        }
      },
        onError: { [weak self] error in
          self?.errorMessage.accept(error.localizedDescription)
      })
    .disposed(by: disposeBag)
  }
  
  func handleUserTextInputResult(isOK: Bool, text: String) {
    guard let authState = self.authState else { return }
    
    switch authState {
    case .waitingForDisplayName(_):
      userSessionRepository.handleUserSelectFactorToLogIn(name: text)
    case .waitingForVerificationCode(_):
      userSessionRepository.handleUserSelectedVerificationCode(text)
    default:
      break
    }
  }
  
}
