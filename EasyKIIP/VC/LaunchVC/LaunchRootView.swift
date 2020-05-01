//
//  LaunchRootView.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class LaunchRootView: NiblessView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    styleViews()
  }
  
  private func styleViews() {
    backgroundColor = UIColor.systemBlue
  }
  
}
