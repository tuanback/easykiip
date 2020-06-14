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
import EasyKIIPKit

class MainVC: NiblessViewController {
  
  private let viewModel: MainViewModel
  private let navigator: MainNavigator
  
  private let disposeBag = DisposeBag()
  
  init(viewModel: MainViewModel,
              navigator: MainNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
  }
  
  override func loadView() {
    view = MainRootView(viewModel: viewModel)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavBar()
    observeViewModel()
  }
  
  deinit {
    print("Deinit")
  }
  
  func setupNavBar() {
    navigationItem.title = "KIIP"
    
    let searchController = UISearchController(searchResultsController: nil)
    navigationItem.searchController = searchController
    
    //navigationController?.navigationBar.prefersLargeTitles = true
    setupMenuButton()
    /*
     let frame = CGRect(x: 0, y: 0, width: 300, height: 30)
     let titleView = UILabel(frame: frame)
     titleView.text = "Test"
     titleView.textColor = UIColor.appLabelColor
     navigationItem.titleView = titleView
     */
  }
  
  private func setupMenuButton() {
    let button = UIButton()
    button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    button.layer.cornerRadius = 0.5 * button.bounds.size.width
    button.setImage(UIImage(named: IconName.avatar), for: .normal)
    button.addTarget(self, action: #selector(handleSettingButtonClicked(_:)), for: .touchUpInside)
    let barButton = UIBarButtonItem()
    barButton.customView = button
    self.navigationItem.rightBarButtonItem = barButton
  }
  
  @objc func handleSettingButtonClicked(_ barButton: UIBarButtonItem) {
    viewModel.handleSettingButtonClicked()
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
