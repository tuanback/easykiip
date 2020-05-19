//
//  MainNavVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/02.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class MainNavVC: NiblessNavigationController {
  
  private let viewModel: MainNavViewModel
  
  private let disposeBag = DisposeBag()
  
  public init(viewModel: MainNavViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
  }
  
  private func observeViewModel() {
    viewModel.oNavigation
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] event in
        switch event {
        case .push(let vc):
          self?.pushViewController(vc, animated: true)
        case .pop:
          self?.popViewController(animated: true)
        case .dismiss:
          self?.dismiss(animated: true, completion: nil)
        default:
          break
        }
      })
    .disposed(by: disposeBag)
  }
}
