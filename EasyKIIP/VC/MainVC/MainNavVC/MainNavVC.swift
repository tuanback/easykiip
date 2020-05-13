//
//  MainNavVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/02.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class MainNavVC: NiblessNavigationController {
  
  private let viewModel: MainNavViewModel
  private let makeMainVC: ()->(MainVC)
  
  private let disposeBag = DisposeBag()
  
  public init(viewModel: MainNavViewModel,
              makeMainVC: @escaping ()->(MainVC)) {
    self.viewModel = viewModel
    self.makeMainVC = makeMainVC
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
          case .main:
            let mainVC = strongSelf.makeMainVC()
            self?.pushViewController(mainVC, animated: true)
          case .bookDetail:
            break
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
extension MainNavVC {

  func hideOrShowNavigationBarIfNeeded(for view: SignedInView, animated: Bool) {
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
extension MainNavVC: UINavigationControllerDelegate {

  public func navigationController(_ navigationController: UINavigationController,
                                   willShow viewController: UIViewController,
                                   animated: Bool) {
    guard let viewToBeShown = signedInView(associatedWith: viewController) else { return }
    hideOrShowNavigationBarIfNeeded(for: viewToBeShown, animated: animated)
  }
}

extension MainNavVC {
  
  func signedInView(associatedWith viewController: UIViewController) -> SignedInView? {
    switch viewController {
    case is MainVC:
      return .main
    case is BookDetailVC:
      return .bookDetail(nil)
    default:
      assertionFailure("Encountered unexpected child view controller type in OnboardingViewController")
      return nil
    }
  }
}
