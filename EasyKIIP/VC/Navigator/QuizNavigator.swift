//
//  QuizNavigator.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/07.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class QuizNavigator: Navigator {
  
  enum Destination {
    case endQuiz
    case showVideoAds
  }
  
  typealias Factory = EndQuizAdVCFactory & VideoAdsVCFactory
  
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
    case .endQuiz:
      return factory.makeEndQuizVC()
    case .showVideoAds:
      return factory.makeVideoAdsVC()
    }
  }
  
}

protocol EndQuizAdVCFactory {
  func makeEndQuizVC() -> UIViewController
}

protocol VideoAdsVCFactory {
  func makeVideoAdsVC() -> UIViewController
}
