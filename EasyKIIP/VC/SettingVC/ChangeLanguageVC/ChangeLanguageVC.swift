//
//  ChangeLanguageVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/14.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class ChangeLanguageVC: NiblessViewController {
  
  private let viewModel: ChangeLanguageViewModel
  
  init(viewModel: ChangeLanguageViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = ChangeLanguageRootView(viewModel: viewModel)
  }
}
