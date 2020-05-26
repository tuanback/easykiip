//
//  WelcomeVC.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class WelcomeVC: NiblessViewController {
  
  private let viewModel: WelcomeViewModel
  
  init(viewModel: WelcomeViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = WelcomeRootView(viewModel: viewModel)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
}
