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
import RxAppState

class LessonDetailVC: NiblessViewController {
  
  private lazy var viewButtonContainer = UIView()
  private lazy var stackViewButtonContainer = UIStackView()
  private lazy var viewCurrentVCIndicator = UIView()
  private lazy var viewViewControllerContainer = UIView()
  private lazy var buttonPractice = UIButton()
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
  
  let navigator: LessonDetailNavigator
  let viewModel: LessonDetailViewModel
  
  private var lastOpenedVC: LessonDetailNavigator.Destination?
  private var startOpeningAnotherVCTime: Double?
  private var shouldPresentAd = false
  private var isVCJustEntering = true
  
  private lazy var adLoader = InterstitialAdLoader(adUnitID: AdsIdentifier.id(for: .interstitial))
  
  init(viewModel: LessonDetailViewModel,
       navigator: LessonDetailNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
  }
  
  override func loadView() {
    view = UIView()
    view.backgroundColor = UIColor.appBackground
    setupViews()
    adLoader.load()
  }
  
  override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)
    
    if parent == nil {
      // Save practice history When the view controller is removed from navigation controller
      viewModel.handleFinishLearning()
    }
  }
  
  private func setupViews() {
    
    stackViewButtonContainer.axis = .horizontal
    stackViewButtonContainer.alignment = .fill
    stackViewButtonContainer.distribution = .fillEqually
    
    buttonPractice.setImage(UIImage(named: IconName.buttonPractice), for: .normal)
    buttonPractice.backgroundColor = UIColor.appRed
    buttonPractice.layer.cornerRadius = 30
    buttonPractice.addTarget(self, action: #selector(didButtonPracticeClicked(sender:)), for: .touchUpInside)
    
    view.addSubview(viewButtonContainer)
    view.addSubview(viewViewControllerContainer)
    view.addSubview(buttonPractice)
    
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
    
    buttonPractice.snp.makeConstraints { (make) in
      make.bottom.equalToSuperview().inset(50)
      make.trailing.equalToSuperview().inset(20)
      make.size.equalTo(60)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if isVCJustEntering {
      isVCJustEntering = false
    }
    else {
      // TODO: only reload the view model if return from quiz vc
      guard let destination = lastOpenedVC else { return }
      switch destination {
      case .quizNewWord(_, _, _), .quizPractice(_, _, _):
        viewModel.reload()
      case .paragraph(_):
        guard let startTime = startOpeningAnotherVCTime else { break }
        let currentTime = Date().timeIntervalSince1970
        let passedTime = currentTime - startTime
        if passedTime >= 60 {
          shouldPresentAd = true
        }
      }
    }
    lastOpenedVC = nil
    startOpeningAnotherVCTime = nil
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentAdIfNeeded()
  }
  
  private func presentAdIfNeeded() {
    if shouldPresentAd {
      shouldPresentAd = false
      adLoader.present(viewController: self)
    }
  }
  
  private func observeViewModel() {
    // Save practice history if the app move to background
    UIApplication.shared.rx.applicationDidEnterBackground
      .subscribe(onNext: { [weak self] _ in
        self?.viewModel.handleFinishLearning()
      })
      .disposed(by: disposeBag)
    
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
    
    viewModel.oNavigationEvent
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] event in
        guard let strongSelf = self else { return }
        switch event {
        case .pop:
          self?.navigationController?.popViewController(animated: true)
        case .dismiss:
          self?.dismiss(animated: true, completion: nil)
        case .present(let destination):
          self?.lastOpenedVC = destination
          self?.startOpeningAnotherVCTime = Date().timeIntervalSince1970
          self?.navigator.navigate(from: strongSelf, to: destination, type: .present)
        case .push(let destination):
          self?.lastOpenedVC = destination
          self?.startOpeningAnotherVCTime = Date().timeIntervalSince1970
          self?.navigator.navigate(from: strongSelf, to: destination, type: .push)
        }
      })
    .disposed(by: disposeBag)
    
    viewModel.oPracticeButtonHidden
      .drive(buttonPractice.rx.isHidden)
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
  
  @objc func didButtonPracticeClicked(sender: UIButton) {
    viewModel.handlePracticeButtonClicked()
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
    pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
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
