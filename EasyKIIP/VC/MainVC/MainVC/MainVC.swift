//
//  MainVC.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class MainVC: NiblessViewController {

  private let viewModel: MainViewModel
  
  public init(viewModel: MainViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  public override func loadView() {
    view = MainRootView(viewModel: viewModel)
  }
    
  

}
