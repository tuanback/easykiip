//
//  SettingNavigator.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/14.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class SettingNavigator: Navigator {
  
  enum Destination {
    case login(signedInResponder: SignedInResponder?)
    case changeLanguage
    case payWall
  }
  
  typealias Factory = LoginVCFactory & LanguageSettingVCFactory & PayWallVCFactory
  
  private let factory: Factory
  init(factory: Factory) {
    self.factory = factory
  }
  
  func navigate(from viewController: UIViewController,
                to destination: Destination,
                type: NavigationType) {
    
    let vc = makeVC(for: destination)
    
    switch type {
    case .present:
      vc.modalPresentationStyle = .fullScreen
      viewController.present(vc, animated: true, completion: nil)
    case .push:
      if let nav = (viewController as? UINavigationController) ?? viewController.navigationController {
        //push root controller on navigation stack
        nav.pushViewController(vc, animated: true)
        return
      }
      viewController.present(vc, animated: true, completion: nil)
    }
  }
  
  private func makeVC(for destination: Destination) -> UIViewController {
    switch destination {
    case .login(let signedInResponder):
      return factory.makeLoginVC(signedInResponder: signedInResponder)
    case .changeLanguage:
      return factory.makeLanguageSettingVC()
    case .payWall:
      return factory.makePayWallVC()
    }
  }
  
}

protocol LanguageSettingVCFactory {
  func makeLanguageSettingVC() -> UIViewController
}
