//
//  SettingVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class SettingVC: NiblessViewController {
  
  private var viewModel: SettingVM
  private var navigator: SettingNavigator
  
  private let disposeBag = DisposeBag()
  
  init(viewModel: SettingVM, navigator: SettingNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
  }
  
  override func loadView() {
    view = SettingRootView(viewModel: viewModel)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.loadSettingItems()
    setupNavBar()
  }
  
  private func setupNavBar() {
    navigationItem.title = Strings.settings
    
    let doneButton = UIBarButtonItem(title: Strings.done, style: .done, target: self, action: #selector(handleDoneButtonClicked(_:)))
    doneButton.tintColor = UIColor.appRed
    navigationItem.rightBarButtonItem = doneButton
  }
  
  @objc func handleDoneButtonClicked(_ barButton: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func observeViewModel() {
    viewModel.oNavigation
    .subscribe(onNext: { [weak self] event in
      guard let strongSelf = self else { return }
      switch event {
      case .push(let destination):
        strongSelf.navigator.navigate(from: strongSelf, to: destination, type: .push)
      case .present(let destination):
        strongSelf.navigator.navigate(from: strongSelf, to: destination, type: .present)
      case .pop:
        self?.navigationController?.popViewController(animated: true)
      case .dismiss:
        self?.dismiss(animated: true, completion: nil)
      }
    })
    .disposed(by: disposeBag)
  }
  
}
