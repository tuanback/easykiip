//
//  QuizNewWordVC.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/09.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class QuizNewWordVC: NiblessViewController {
  
  private let viewModel: QuizNewWordViewModel
  
  init(viewModel: QuizNewWordViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = QuizNewWordRootView(viewModel: viewModel)
  }
  
}
