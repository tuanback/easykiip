//
//  LaunchVC.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class LaunchVC: NiblessViewController {
  
  private let viewModel: LaunchViewModel
  private let makeOnboardingVC: () -> (OnboardingVC)
  private let makeMainVC: ()->(MainVC)
  
  private let disposeBag = DisposeBag()
  
  public init(viewModel: LaunchViewModel,
              makeOnboardingVC: @escaping () -> (OnboardingVC),
              makeMainVC: @escaping () -> (MainVC)) {
    self.viewModel = viewModel
    self.makeOnboardingVC = makeOnboardingVC
    self.makeMainVC = makeMainVC
    super.init()
  }
  
  public override func loadView() {
    view = LaunchRootView()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.start()
  }
  
  private func observeViewModel() {
    viewModel.oNavigation
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] event in
        guard let strongSelf = self else { return }
        switch event {
        case .present(let view):
          switch view {
          case .onboarding:
            let onboardingVC = strongSelf.makeOnboardingVC()
            onboardingVC.modalPresentationStyle = .fullScreen
            strongSelf.present(onboardingVC, animated: true, completion: nil)
          case .main:
            let mainVC = strongSelf.makeMainVC()
            mainVC.modalPresentationStyle = .fullScreen
            strongSelf.present(mainVC, animated: true, completion: nil)
          }
        default:
          break
        }
      })
    .disposed(by: disposeBag)
  }
  
}
