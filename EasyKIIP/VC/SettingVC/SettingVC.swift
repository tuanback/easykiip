//
//  SettingVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class SettingVC: NiblessViewController {
  
  private let viewModel: SettingVM
  
  init(viewModel: SettingVM) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = SettingRootView(viewModel: viewModel)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
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
    
  }
  
}
