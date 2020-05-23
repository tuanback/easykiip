//
//  OnboardingNavigator.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/23.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class OnboardingNavigator: Navigator {
  
  enum Destination {
    case login
    case welcome
  }
  
  typealias Factory = LoginVCFactory & WelcomeVCFactory
  
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
        nav.pushViewController(vc, animated: false)
        return
      }
      viewController.present(vc, animated: true, completion: nil)
    }
  }
  
  private func makeVC(for destination: Destination) -> UIViewController {
    switch destination {
    case .login:
      return factory.makeLoginVC()
    case .welcome:
      return factory.makeWelcomeVC()
    }
  }
  
}

protocol LoginVCFactory {
  func makeLoginVC() -> LoginVC
}

protocol WelcomeVCFactory {
  func makeWelcomeVC() -> WelcomeVC
}
