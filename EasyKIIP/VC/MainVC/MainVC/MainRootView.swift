//
//  MainRootView.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MainRootView: NiblessView {
  
  private let viewModel: MainViewModel
  
  init(frame: CGRect = .zero,
       viewModel: MainViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    backgroundColor = UIColor.systemTeal
  }
  
}
