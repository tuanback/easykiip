//
//  LoginVC.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

public class LoginVC: NiblessViewController {
  
  private let viewModel: LoginViewModel
  
  public init(viewModel: LoginViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  public override func loadView() {
    view = LoginRootView(viewModel: viewModel)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
  }
  
}
