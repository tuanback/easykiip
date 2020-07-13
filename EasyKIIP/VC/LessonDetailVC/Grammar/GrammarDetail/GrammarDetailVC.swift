//
//  GrammarDetailVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/07/12.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit

class GrammarDetailVC: NiblessViewController {
  
  private let viewModel: GrammarDetailViewModel
  
  init(viewModel: GrammarDetailViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = GrammarDetailRootView(viewModel: viewModel)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = Strings.grammar
  }
}
