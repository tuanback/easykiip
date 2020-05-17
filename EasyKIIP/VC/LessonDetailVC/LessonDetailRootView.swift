//
//  LessonDetailRootView.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/17.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class LessonDetailRootView: NiblessView {
  
  let viewModel: LessonDetailViewModel
  
  init(frame: CGRect = .zero,
       viewModel: LessonDetailViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    
    backgroundColor = UIColor.appBackground
    
  }
  
}
