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
  private let makeLoginVC: ()->(LoginVC)
  private let makeWelcomeVC: ()->(WelcomeVC)
  
  private let disposeBag = DisposeBag()
  
  public init(viewModel: OnboardingVM,
              makeWelcomeVC: @escaping ()->(WelcomeVC),
              makeLoginVC: @escaping ()->(LoginVC)) {
    self.viewModel = viewModel
    self.makeWelcomeVC = makeWelcomeVC
    self.makeLoginVC = makeLoginVC
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
        case .push(let view):
          switch view {
          case .login:
            let loginVC = strongSelf.makeLoginVC()
            strongSelf.pushViewController(loginVC, animated: true)
          case .welcome:
            let welcomeVC = strongSelf.makeWelcomeVC()
            strongSelf.pushViewController(welcomeVC, animated: false)
          }
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

  func hideOrShowNavigationBarIfNeeded(for view: OnboardingView, animated: Bool) {
    if view.hidesNavigationBar() {
      hideNavigationBar(animated: animated)
    } else {
      showNavigationBar(animated: animated)
    }
  }

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
    guard let viewToBeShown = onboardingView(associatedWith: viewController) else { return }
    hideOrShowNavigationBarIfNeeded(for: viewToBeShown, animated: animated)
  }
}

extension OnboardingVC {
  
  func onboardingView(associatedWith viewController: UIViewController) -> OnboardingView? {
    switch viewController {
    case is WelcomeVC:
      return .welcome
    case is LoginVC:
      return .login
    default:
      assertionFailure("Encountered unexpected child view controller type in OnboardingViewController")
      return nil
    }
  }
}
