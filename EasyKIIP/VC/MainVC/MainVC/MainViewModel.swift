//
//  MainViewModel.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UserSession
import EasyKIIPKit

public class MainViewModel {
  
  private let userSessionRepository: UserSessionRepository
  private let vocabRepository: VocabRepository
  
  public init(userSessionRepository: UserSessionRepository,
       vocabRepository: VocabRepository) {
    self.userSessionRepository = userSessionRepository
    self.vocabRepository = vocabRepository
  }
  
  
  
  
  
}
