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

public class OnboardingVC: NiblessNavigationController {

  private let viewModel: OnboardingVM
  
  private let disposeBag = DisposeBag()
  
  public init(viewModel: OnboardingVM) {
    self.viewModel = viewModel
    super.init()
    self.delegate = self
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
  }
  
  private func observeViewModel() {
    viewModel.oNavigation
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] event in
        guard let strongSelf = self else { return }
        switch event {
        case .push(let vc):
          strongSelf.pushViewController(vc, animated: true)
        case .pop:
          self?.popViewController(animated: true)
        case .dismiss:
          self?.dismiss(animated: true, completion: nil)
        default:
          break
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
      hideNavigationBar(animated: animated)
    } else {
      showNavigationBar(animated: animated)
    }
  }
}

extension OnboardingVC {
  
  func shouldShowNavBar(associatedWith viewController: UIViewController) -> Bool? {
    switch viewController {
    case is WelcomeVC:
      return false
    case is LoginVC:
      return true
    default:
      assertionFailure("Encountered unexpected child view controller type in OnboardingViewController")
      return nil
    }
  }
}
