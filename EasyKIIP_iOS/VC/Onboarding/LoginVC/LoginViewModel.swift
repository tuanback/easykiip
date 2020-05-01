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

public class LoginViewModel {
  
  private let userSessionRepository: UserSessionRepository
  private let signedInResponder: SignedInResponder
  
  init(userSessionRepository: UserSessionRepository,
       signedInResponder: SignedInResponder) {
    self.userSessionRepository = userSessionRepository
    self.signedInResponder = signedInResponder
  }
  
  
  
}
