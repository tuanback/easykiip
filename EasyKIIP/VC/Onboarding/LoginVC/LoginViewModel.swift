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
import KakaoOpenSDK

public class LoginViewModel {
  
  private let userSessionRepository: UserSessionRepository
  private var signedInResponder: SignedInResponder?
  
  var textInput = PublishRelay<String>()
  var errorMessage = PublishRelay<String>()
  
  var oDismiss: Observable<Void> {
    return rDismiss.asObservable()
  }
  private var rDismiss = PublishRelay<Void>()
  
  var oIsLoading: Observable<Bool> {
    return rIsLoading.asObservable()
  }
  private var rIsLoading = PublishRelay<Bool>()
  
  private var authState: AuthState?
  private let disposeBag = DisposeBag()
  
  init(userSessionRepository: UserSessionRepository,
       signedInResponder: SignedInResponder?) {
    self.userSessionRepository = userSessionRepository
    self.signedInResponder = signedInResponder
  }
  
  func login(with credential: AuthCredential, provider: Provider) {
    rIsLoading.accept(true)
    guard let userSessionRepository = self.userSessionRepository as? FirebaseUserSessionRepository else {
      return
    }
    let observerble = userSessionRepository.signIn(with: credential, provider: provider)
    handleLoginEvent(observerble: observerble)
  }
  
  private func handleLoginEvent(observerble: Observable<AuthState>) {
    observerble
      .subscribe(
        onNext: { [weak self] state in
          self?.authState = state
          switch state {
          case .waitingForDisplayName(let displayName):
            self?.textInput.accept("Select factor to sign in\n\(displayName)")
            self?.rIsLoading.accept(false)
          case .waitingForVerificationCode(let displayName):
            self?.textInput.accept("Verification code for \(displayName)")
            self?.rIsLoading.accept(false)
          case .success(_):
            self?.rIsLoading.accept(false)
            if let responder = self?.signedInResponder {
              responder.signedIn()
            }
            else {
              self?.rDismiss.accept(())
            }
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
    guard let userSessionRepository = self.userSessionRepository as? FirebaseUserSessionRepository else {
      return
    }
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
  
  func kakaoLogin() {
    guard let session = KOSession.shared() else { return }
    
    if session.isOpen() {
      session.close()
    }
    
    session.open { (error) -> Void in
      if let err = error {
        print(err)
      }
      else {
        print(session.token)
      }
    }
  }
  
  func handleCloseButtonClicked() {
    rDismiss.accept(())
  }
}
