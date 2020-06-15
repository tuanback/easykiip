//
//  ParagraphViewVC.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/15.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class ParagraphViewVC: NiblessViewController {
  
  private let viewModel: ParagraphViewVM
  
  init(viewModel: ParagraphViewVM) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = ParagraphViewRootView(viewModel: viewModel)
  }
  
}
