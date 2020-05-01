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

class LoginRootView: NiblessView {
  
  private let viewModel: LoginViewModel
  
  init(frame: CGRect = .zero,
       viewModel: LoginViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    backgroundColor = UIColor.appBackground
  }
  
}
