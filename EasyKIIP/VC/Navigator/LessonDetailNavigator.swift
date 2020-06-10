//
//  LessonDetailNavigator.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/10.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import EasyKIIPKit

class LessonDetailNavigator: Navigator {
  
  enum Destination {
    case quizNewWord(bookID: Int, lessonID: Int, vocabs: [Vocab])
  }
  
  typealias Factory = QuizNewWordVCFactory
  
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
    case .quizNewWord(let bookID, let lessonID, let vocabs):
      return factory.makeQuizNewWordVC(bookID: bookID, lessonID: lessonID, vocabs: vocabs)
    }
  }
  
}

protocol QuizNewWordVCFactory {
  func makeQuizNewWordVC(bookID: Int, lessonID: Int, vocabs: [Vocab]) -> QuizVC
}
