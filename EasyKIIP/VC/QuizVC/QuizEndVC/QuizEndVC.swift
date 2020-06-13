//
//  QuizEndVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class QuizEndVC: NiblessViewController {
  
  private let viewModel: QuizEndViewModel
  
  private let disposeBag = DisposeBag()
  
  init(viewModel: QuizEndViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = QuizEndRootView(viewModel: viewModel)
    observeViewModel()
  }
  
  private func observeViewModel() {
    viewModel.oDismiss
      .subscribe(onNext: { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
  }
  
}
