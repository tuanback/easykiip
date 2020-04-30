//
//  OnboardingVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit

public class OnboardingVC: NiblessNavigationController {

  private let viewModel: OnboardingVM
  
  public init(viewModel: OnboardingVM) {
    self.viewModel = viewModel
    super.init()
  }
  
  public override func loadView() {
    view = OnboardingRootView()
  }
  

}
