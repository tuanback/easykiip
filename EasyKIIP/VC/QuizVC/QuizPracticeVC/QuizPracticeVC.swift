//
//  QuizPracticeVC.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/10.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class QuizPracticeVC: NiblessViewController {
  
  private let viewModel: QuizPracticeViewModel
  
  init(viewModel: QuizPracticeViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = QuizPracticeRootView(viewModel: viewModel)
  }
  
}
