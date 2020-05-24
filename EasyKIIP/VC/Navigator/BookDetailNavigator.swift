//
//  BookDetailNavigator.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

class BookDetailNavigator: Navigator {
  
  enum Destination {
    case lessonDetail(bookID: Int, lessonID: Int)
  }
  
  typealias Factory = LessonDetailVCFactory
  
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
    case .lessonDetail(let bookID, let lessonID):
      return factory.makeLessonDetailVC(bookID: bookID, lessonID: lessonID)
    }
  }
  
}

protocol LessonDetailVCFactory {
  func makeLessonDetailVC(bookID: Int, lessonID: Int) -> LessonDetailVC
}
