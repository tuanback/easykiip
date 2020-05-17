//
//  LessonDetailVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/17.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class LessonDetailVC: NiblessViewController {
  
  let viewModel: LessonDetailViewModel
  
  init(viewModel: LessonDetailViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = UIView()
    view.backgroundColor = UIColor.appRed
  }
  
}
