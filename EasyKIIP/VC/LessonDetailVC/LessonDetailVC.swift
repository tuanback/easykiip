//
//  LessonDetailVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/17.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class LessonDetailVC: NiblessViewController {
  
  private lazy var viewButtonContainer = UIView()
  private lazy var stackViewButtonContainer = UIStackView()
  private lazy var viewCurrentVCIndicator = UIView()
  private lazy var viewViewControllerContainer = UIView()
  private var buttonLearn: UIButton?
  private var buttonReading: UIButton?
  private var buttonVocabList: UIButton?
  
  private let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                navigationOrientation: .horizontal,
                                                options: nil)
  private var viewControllers: [UIViewController] = []
  private var learnListVC: LearnVocabListVC?
  private var readingListVC: ReadingListVC?
  private var vocabListVC: VocabListVC?
  private var currentVCIndex = 0
  
  private let disposeBag = DisposeBag()
  
  let viewModel: LessonDetailViewModel
  
  init(viewModel: LessonDetailViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = UIView()
    view.backgroundColor = UIColor.appBackground
    setupViews()
  }
  
  private func setupViews() {
    
    stackViewButtonContainer.axis = .horizontal
    stackViewButtonContainer.alignment = .fill
    stackViewButtonContainer.distribution = .fillEqually
    
    view.addSubview(viewButtonContainer)
    view.addSubview(viewViewControllerContainer)
    
    let separator = UIView()
    separator.backgroundColor = UIColor.systemGray
    
    viewButtonContainer.addSubview(stackViewButtonContainer)
    viewButtonContainer.addSubview(separator)
    viewButtonContainer.addSubview(viewCurrentVCIndicator)
    
    viewCurrentVCIndicator.backgroundColor = UIColor.appRed
    viewCurrentVCIndicator.isHidden = true
    
    stackViewButtonContainer.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    viewButtonContainer.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.equalTo(view.safeAreaLayoutGuide)
      make.trailing.equalTo(view.safeAreaLayoutGuide)
      make.height.equalTo(40)
    }
    
    separator.snp.makeConstraints { (make) in
      make.height.equalTo(0.5)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    viewViewControllerContainer.snp.makeConstraints { [viewButtonContainer] (make) in
      make.top.equalTo(viewButtonContainer.snp.bottom)
      make.leading.equalTo(view.safeAreaLayoutGuide)
      make.trailing.equalTo(view.safeAreaLayoutGuide)
      make.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
  }
  
  private func observeViewModel() {
    viewModel.oNavigationTitle
      .drive(navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    viewModel.childVC
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] childVCs in
        guard let strongSelf = self else { return }
        
        strongSelf.viewControllers.removeAll()
        strongSelf.stackViewButtonContainer.arrangedSubviews.forEach {
          $0.removeFromSuperview()
        }
        
        for childVC in childVCs {
          switch childVC {
          case .learnVocab:
            let vc = LearnVocabListVC(viewModel: strongSelf.viewModel)
            strongSelf.learnListVC = vc
            strongSelf.viewControllers.append(vc)
            let button = strongSelf.setupLearnVocabButton()
            strongSelf.stackViewButtonContainer.addArrangedSubview(button)
          case .readingPart:
            let vc = ReadingListVC(viewModel: strongSelf.viewModel)
            strongSelf.readingListVC = vc
            strongSelf.viewControllers.append(vc)
            let button = strongSelf.setupParagraphButton()
            strongSelf.stackViewButtonContainer.addArrangedSubview(button)
          case .listOfVocabs:
            let vc = VocabListVC(viewModel: strongSelf.viewModel)
            strongSelf.vocabListVC = vc
            strongSelf.viewControllers.append(vc)
            let button = strongSelf.setupVocabularyButton()
            strongSelf.stackViewButtonContainer.addArrangedSubview(button)
          }
        }
        
        guard strongSelf.viewControllers.count > 0 else { return }
        strongSelf.setupPageViewController(with: strongSelf.viewControllers)
        
        strongSelf.updateIndicatorView(leading: 0, width: strongSelf.view.frame.width / 3)
      })
      .disposed(by: disposeBag)
  }
  
  private func setupLearnVocabButton() -> UIButton {
    buttonLearn = UIButton()
    buttonLearn?.setTitle(Strings.learn, for: .normal)
    buttonLearn?.titleLabel?.font = UIFont.appFontDemiBold(ofSize: 16)
    buttonLearn?.addTarget(self, action: #selector(handleButtonLearnClicked(_:)), for: .touchUpInside)
    buttonLearn?.setTitleColor(UIColor.appLabelBlack, for: .normal)
    return buttonLearn!
  }
  
  @objc func handleButtonLearnClicked(_ sender: UIButton) {
    guard let vc = learnListVC,
      let index = indexOfViewController(vc),
      index != currentVCIndex else {
      return
    }
    
    let direction: UIPageViewController.NavigationDirection = currentVCIndex < index ? .forward : .reverse
    currentVCIndex = index
    pageViewController.setViewControllers([vc], direction: direction, animated: true, completion: nil)
    updateIndicatorView(view: sender)
  }
  
  private func setupParagraphButton() -> UIButton {
    buttonReading = UIButton()
    buttonReading?.setTitle(Strings.paragraph, for: .normal)
    buttonReading?.titleLabel?.font = UIFont.appFontDemiBold(ofSize: 16)
    buttonReading?.addTarget(self, action: #selector(handleButtonParagraphClicked(_:)), for: .touchUpInside)
    buttonReading?.setTitleColor(UIColor.appLabelBlack, for: .normal)
    return buttonReading!
  }
  
  @objc func handleButtonParagraphClicked(_ sender: UIButton) {
    guard let vc = readingListVC,
      let index = indexOfViewController(vc),
      index != currentVCIndex else {
        return
    }
    
    let direction: UIPageViewController.NavigationDirection = currentVCIndex < index ? .forward : .reverse
    currentVCIndex = index
    pageViewController.setViewControllers([vc], direction: direction, animated: true, completion: nil)
    updateIndicatorView(view: sender)
  }
  
  private func setupVocabularyButton() -> UIButton {
    buttonVocabList = UIButton()
    buttonVocabList?.setTitle(Strings.vocabulary, for: .normal)
    buttonVocabList?.titleLabel?.font = UIFont.appFontDemiBold(ofSize: 16)
    buttonVocabList?.setTitleColor(UIColor.appLabelBlack, for: .normal)
    buttonVocabList?.addTarget(self, action: #selector(handleButtonVocabularClicked), for: .touchUpInside)
    return buttonVocabList!
  }
  
  @objc func handleButtonVocabularClicked(_ sender: UIButton) {
    guard let vc = vocabListVC,
      let index = indexOfViewController(vc),
      index != currentVCIndex else {
      return
    }
    
    let direction: UIPageViewController.NavigationDirection = currentVCIndex < index ? .forward : .reverse
    currentVCIndex = index
    pageViewController.setViewControllers([vc], direction: direction, animated: true, completion: nil)
    updateIndicatorView(view: sender)
  }
  
  private func updateIndicatorView(view: UIView) {
    let frame = view.frame
    updateIndicatorView(leading: frame.origin.x, width: frame.width)
  }
  
  private func updateIndicatorView(leading: CGFloat, width: CGFloat) {
    viewCurrentVCIndicator.isHidden = false
    
    UIView.animate(withDuration: 0.5) {
      self.viewCurrentVCIndicator.snp.remakeConstraints { (make) in
        make.bottom.equalToSuperview()
        make.height.equalTo(1.5)
        make.leading.equalTo(leading)
        make.width.equalTo(width)
      }
    }
  }
  
  private func setupPageViewController(with viewControllers: [UIViewController]) {
    pageViewController.delegate = self
    pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: true, completion: nil)
    pageViewController.dataSource = self
    
    addChild(pageViewController)
    viewViewControllerContainer.addSubview(pageViewController.view)
    pageViewController.didMove(toParent: self)
    
    view.gestureRecognizers = pageViewController.gestureRecognizers
    
    pageViewController.view.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
  
}

extension LessonDetailVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard var index = indexOfViewController(viewController),
      index >= 1 else { return nil }
    
    index -= 1
    
    return viewControllerAtIndex(index)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard var index = indexOfViewController(viewController), index < viewControllers.count - 1 else { return nil }
    
    index += 1
    return viewControllerAtIndex(index)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return }
    
    if let vc = pageViewController.viewControllers?.first,
      let index = indexOfViewController(vc) {
      currentVCIndex = index
      let width = self.view.frame.width / 3
      let leading = width * CGFloat(index)
      updateIndicatorView(leading: leading, width: width)
      print(index)
    }
  }
}

extension LessonDetailVC {
  private func viewControllerAtIndex(_ index: Int) -> UIViewController? {
    if viewControllers.count == 0 || index >= viewControllers.count {
      return nil
    }
    return viewControllers[index]
  }
  
  private func indexOfViewController(_ viewController: UIViewController) -> Int? {
    return viewControllers.firstIndex(of: viewController)
  }
}
