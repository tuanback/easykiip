//
//  LaunchNavigator.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/23.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class LaunchNavigator: Navigator {
  
  enum Destination {
    case onboarding
    case main
  }
  
  typealias Factory = OnboardingVCFactory & MainNavConFactory
  
  private weak var viewController: UIViewController?
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
    case .onboarding:
      return factory.makeOnboardingVC()
    case .main:
      return factory.makeMainNavVC()
    }
  }
  
}

protocol OnboardingVCFactory {
  func makeOnboardingVC() -> OnboardingVC
}

protocol MainNavConFactory {
  func makeMainNavVC() -> MainNavVC
}
