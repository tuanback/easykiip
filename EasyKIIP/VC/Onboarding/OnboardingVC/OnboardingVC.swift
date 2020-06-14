//
//  OnboardingVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OnboardingVC: NiblessNavigationController {

  private let viewModel: OnboardingVM
  private let navigator: OnboardingNavigator
  
  private let disposeBag = DisposeBag()
  
  init(viewModel: OnboardingVM,
              navigator: OnboardingNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
    self.delegate = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
    setNavigationBarHidden(true, animated: true)
  }
  
  private func observeViewModel() {
    viewModel.oNavigation
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] event in
        guard let strongSelf = self else { return }
        switch event {
        case .push(let destination):
          strongSelf.navigator.navigate(from: strongSelf, to: destination, type: .push)
        case .present(let destination):
          strongSelf.navigator.navigate(from: strongSelf, to: destination, type: .present)
        case .pop:
          self?.popViewController(animated: true)
        case .dismiss:
          self?.dismiss(animated: true, completion: nil)
        }
      })
    .disposed(by: disposeBag)
  }
}

// MARK: - Navigation Bar Presentation
extension OnboardingVC {

  func hideNavigationBar(animated: Bool) {
    if animated {
      transitionCoordinator?.animate(alongsideTransition: { context in
        self.setNavigationBarHidden(true, animated: animated)
      })
    } else {
      setNavigationBarHidden(true, animated: false)
    }
  }

  func showNavigationBar(animated: Bool) {
    if self.isNavigationBarHidden {
      self.setNavigationBarHidden(false, animated: animated)
    }
  }
}

// MARK: - UINavigationControllerDelegate
extension OnboardingVC: UINavigationControllerDelegate {

  public func navigationController(_ navigationController: UINavigationController,
                                   willShow viewController: UIViewController,
                                   animated: Bool) {
    guard let shouldShowNavBar = shouldShowNavBar(associatedWith: viewController) else { return }
    if shouldShowNavBar {
      showNavigationBar(animated: animated)
    } else {
      hideNavigationBar(animated: animated)
    }
  }
}

extension OnboardingVC {
  
  func shouldShowNavBar(associatedWith viewController: UIViewController) -> Bool? {
    switch viewController {
    case is WelcomeVC:
      return false
    case is LoginVC:
      return false
    default:
      assertionFailure("Encountered unexpected child view controller type in OnboardingViewController")
      return nil
    }
  }
}
