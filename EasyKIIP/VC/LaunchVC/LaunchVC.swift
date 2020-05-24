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

class LaunchVC: NiblessViewController {
  
  private let viewModel: LaunchViewModel
  private let navigator: LaunchNavigator
  
  private let disposeBag = DisposeBag()
  
  init(viewModel: LaunchViewModel,
              navigator: LaunchNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
  }
  
  override func loadView() {
    view = LaunchRootView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    showLanguageSelectIfNeeded()
  }
  
  private func showLanguageSelectIfNeeded() {
    if AppValuesStorage.didSetLanguage {
      viewModel.start()
      return
    }
      
    let vc = SelectLanguageVC(didSelected: { [weak self] in
      self?.viewModel.start()
    })
    present(vc, animated: true, completion: nil)
  }
  
  private func observeViewModel() {
    viewModel.oNavigation
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] event in
        guard let strongSelf = self else { return }
        switch event {
        case .present(let destination):
          strongSelf.navigator.navigate(from: strongSelf, to: destination, type: .present)
        case .push(let destination):
          strongSelf.navigator.navigate(from: strongSelf, to: destination, type: .push)
        default:
          break
        }
      })
    .disposed(by: disposeBag)
  }
  
}
