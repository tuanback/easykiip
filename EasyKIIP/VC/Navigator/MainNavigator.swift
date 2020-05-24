//
//  MainNavigator.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/23.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class MainNavigator: Navigator {
  
  enum Destination {
    case bookDetail(bookID: Int, bookName: String)
  }
  
  typealias Factory = BookDetailFactory
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
    case .bookDetail(let bookID, let bookName):
      return factory.makeBookDetailVC(bookID: bookID, bookName: bookName)
    }
  }
  
}

protocol BookDetailFactory {
  
  func makeBookDetailVC(bookID: Int, bookName: String) -> BookDetailVC
  
}
