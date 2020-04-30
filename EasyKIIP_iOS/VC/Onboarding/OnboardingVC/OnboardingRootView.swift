//
//  OnboardingView.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class OnboardingRootView: NiblessView {
  
  private var labelLogo: UILabel!
  private var labelTitle: UILabel!
  private var lableMessage: UILabel!
  private var loginButton: UIButton!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    styleView()
    setupViews()
  }
  
  private func styleView() {
    backgroundColor = UIColor.primaryColor
  }
  
  private func setupViews() {
    
    
    
  }
  
}
