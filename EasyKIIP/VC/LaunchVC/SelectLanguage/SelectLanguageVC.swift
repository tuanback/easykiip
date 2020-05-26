//
//  SelectLanguageVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit

class SelectLanguageVC: NiblessViewController {
  
  private let didSelected: ()->()
  
  init(didSelected: @escaping ()->()) {
    self.didSelected = didSelected
    super.init()
    modalPresentationStyle = .overCurrentContext
    modalTransitionStyle = .crossDissolve
  }
  
  override func loadView() {
    view = SelectLanguageRootView(didLanguageSelected: { [weak self] language in
      AppSetting.languageCode = language.languageCode
      AppValuesStorage.didSetLanguage = true
      self?.didSelected()
      self?.dismiss(animated: true, completion: nil)
    })
    view.backgroundColor = UIColor.systemGray
  }
}
