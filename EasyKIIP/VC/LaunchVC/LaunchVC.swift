//
//  LaunchVC.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class LaunchVC: NiblessViewController {
  
  private let viewModel: LaunchViewModel
  
  private let disposeBag = DisposeBag()
  
  public init(viewModel: LaunchViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  public override func loadView() {
    view = LaunchRootView()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.start()
  }
  
  private func observeViewModel() {
    viewModel.oNavigation
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] event in
        guard let strongSelf = self else { return }
        switch event {
        case .push(let viewController):
          strongSelf.navigationController?.pushViewController(viewController, animated: true)
        case .present(let viewController):
          viewController.modalPresentationStyle = .fullScreen
          strongSelf.present(viewController, animated: true, completion: nil)
        default:
          break
        }
      })
    .disposed(by: disposeBag)
  }
  
}
