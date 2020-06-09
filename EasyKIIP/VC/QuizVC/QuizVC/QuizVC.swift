//
//  QuizVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/07.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class QuizVC: NiblessViewController {
  
  private lazy var buttonClose = UIButton()
  private lazy var stackViewHeart = UIStackView()
  private lazy var viewViewControllerContainer = UIView()
  
  private let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                        navigationOrientation: .horizontal,
                                                        options: nil)
  
  private let disposeBag = DisposeBag()
  
  private let viewModel: QuizViewModel
  private let navigator: QuizNavigator
  
  private var newWordVC: QuizNewWordVC?
  
  init(viewModel: QuizViewModel,
       navigator: QuizNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
  }
  
  override func loadView() {
    view = UIView()
    view.backgroundColor = UIColor.appBackground
    setupViews()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    observeViewModel()
  }
  
  @objc func handleCloseButtonClicked(sender: UIButton) {
    viewModel.handleClose()
  }
  
  private func observeViewModel() {
    
    viewModel.oDisplayingChildVC
      .subscribe(onNext: { [weak self] viewModel in
        guard let strongSelf = self else { return }
        // TODO: To make child view controller then display
        switch viewModel {
        case .newWord(let question):
          let vm = QuizNewWordViewModel(question: question, answerHandler: strongSelf.viewModel)
          strongSelf.newWordVC = QuizNewWordVC(viewModel: vm)
          strongSelf.pageViewController
            .setViewControllers([strongSelf.newWordVC!], direction: .forward,
                                animated: true, completion: nil)
        case .practice(let viewModel):
          break
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.oHeartViewHidden
      .drive(stackViewHeart.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel.oHeart
      .subscribe(onNext: { [weak self] (numberOfHeart, totalHeart) in
        self?.setupStackViewHeart(numberOfHeart: numberOfHeart, totalHeart: totalHeart)
        
      })
      .disposed(by: disposeBag)
    
    // TODO: More to come
    viewModel.oAlerts
      .subscribe(onNext: { [weak self] alert in
        self?.showAlertMessage(alert: alert)
      })
    .disposed(by: disposeBag)
    
    viewModel.oNavigationEvent
      .subscribe(onNext: { [weak self] event in
        guard let strongSelf = self else { return }
        switch event {
        case .dismiss:
          self?.dismiss(animated: true, completion: nil)
        case .pop:
          self?.navigationController?.popViewController(animated: true)
        case .present(let destination):
          self?.navigator.navigate(from: strongSelf, to: destination, type: .present)
        case .push(let destination):
          self?.navigator.navigate(from: strongSelf, to: destination, type: .push)
        }
      })
    .disposed(by: disposeBag)
  }
  
  private func showAlertMessage(alert: AlertWithAction) {
    let alertMessage = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
    
    for action in alert.actions {
      let alertAction = UIAlertAction(title: action.title, style: action.style) { (_) in
        action.handler()
      }
      alertMessage.addAction(alertAction)
    }
    
    present(alertMessage, animated: true, completion: nil)
  }
}

extension QuizVC {
  private func setupViews() {
    
    buttonClose.setImage(UIImage(named: IconName.close), for: .normal)
    buttonClose.addTarget(self, action: #selector(handleCloseButtonClicked(sender:)), for: .touchUpInside)
    stackViewHeart.isHidden = true
    stackViewHeart.axis = .horizontal
    stackViewHeart.alignment = .fill
    stackViewHeart.distribution = .fillEqually
    stackViewHeart.spacing = 4
    
    view.addSubview(buttonClose)
    view.addSubview(stackViewHeart)
    view.addSubview(viewViewControllerContainer)
    
    buttonClose.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(16)
      make.top.equalToSuperview().inset(16)
      make.size.equalTo(44)
    }
    
    stackViewHeart.snp.makeConstraints { (make) in
      make.trailing.equalToSuperview().inset(16)
      make.centerY.equalTo(buttonClose.snp.centerY)
      make.height.equalTo(44)
      make.width.equalTo(0)
    }
    
    viewViewControllerContainer.snp.makeConstraints { (make) in
      make.top.equalTo(buttonClose.snp.bottom).offset(16)
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
    
    setupPageViewController()
  }
  
  private func setupPageViewController() {
    
    addChild(pageViewController)
    viewViewControllerContainer.addSubview(pageViewController.view)
    pageViewController.didMove(toParent: self)
    
    view.gestureRecognizers = pageViewController.gestureRecognizers
    
    pageViewController.view.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    /*
     pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: true, completion: nil)
     */
  }
  
  private func setupStackViewHeart(numberOfHeart: Int, totalHeart: Int) {
    stackViewHeart.snp.updateConstraints({ (make) in
      make.width.equalTo(44 * totalHeart)
    })
    
    stackViewHeart.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    
    for i in 0..<totalHeart {
      let imageView = UIImageView()
      imageView.contentMode = .scaleAspectFit
      if i < numberOfHeart {
        imageView.image = UIImage(named: IconName.heartFill)
      }
      else {
        imageView.image = UIImage(named: IconName.heartEmpty)
      }
      
      stackViewHeart.addArrangedSubview(imageView)
    }
  }
}
