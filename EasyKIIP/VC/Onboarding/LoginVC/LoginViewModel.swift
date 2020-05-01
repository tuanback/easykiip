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
  
  init(userSessionRepository: UserSessionRepository,
       signedInResponder: SignedInResponder) {
    self.userSessionRepository = userSessionRepository
    self.signedInResponder = signedInResponder
    self.listenForUserLoggedIn()
  }
  
  private func listenForUserLoggedIn() {
    
    Auth.auth().addStateDidChangeListener { (auth, user) in
      guard let user = user else {
        print("Not singed in")
        return
      }
      print(user)
    }
  }
}
