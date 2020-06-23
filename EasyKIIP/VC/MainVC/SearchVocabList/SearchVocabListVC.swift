//
//  VocabListVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SearchVocabListVC: NiblessViewController {
  
  private let viewModel: SearchVocabListViewModel
  
  init(viewModel: SearchVocabListViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = SearchVocabListRootView(viewModel: viewModel)
  }
}
