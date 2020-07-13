//
//  ParagraphVC.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/15.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class ParagraphVC: NiblessViewController {
  
  private lazy var viewButtonContainer = UIView()
  private lazy var stackViewButtonContainer = UIStackView()
  private lazy var viewCurrentVCIndicator = UIView()
  private lazy var viewViewControllerContainer = UIView()
  private let buttonKorean = UIButton()
  private let buttonTranslation = UIButton()
  
  private lazy var searchController = UISearchController(searchResultsController: searchVocabListVC)
  
  private let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                        navigationOrientation: .horizontal,
                                                        options: nil)
  private var viewControllers: [UIViewController] = []
  private var currentVCIndex = 0
  private let disposeBag = DisposeBag()
  
  private lazy var searchVocabListVM = SearchVocabListViewModel(vocabs: [])
  private lazy var searchVocabListVC = SearchVocabListVC(viewModel: searchVocabListVM)
  
  private let viewModel: ParagraphViewModel
  
  init(viewModel: ParagraphViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  override func loadView() {
    view = UIView()
    view.backgroundColor = UIColor.appBackground
    setupViews()
  }
  
  private func setupViews() {
    
    navigationItem.title = Strings.paragraph
    
    buttonKorean.setTitle(Strings.korean, for: .normal)
    buttonKorean.titleLabel?.font = UIFont.appFontDemiBold(ofSize: 16)
    buttonKorean.setTitleColor(UIColor.appLabelBlack, for: .normal)
    buttonKorean.addTarget(self, action: #selector(handleButtonKoreanClicked(sender:)), for: .touchUpInside)
    
    var title: String
    switch AppSetting.languageCode {
    case .vi:
      title = Strings.vietnamese
    case .en:
      title = Strings.english
    }
    
    buttonTranslation.setTitle(title, for: .normal)
    buttonTranslation.titleLabel?.font = UIFont.appFontDemiBold(ofSize: 16)
    buttonTranslation.setTitleColor(UIColor.appLabelBlack, for: .normal)
    buttonTranslation.addTarget(self, action: #selector(handleButtonTranslationClicked(sender:)), for: .touchUpInside)
    
    stackViewButtonContainer.axis = .horizontal
    stackViewButtonContainer.alignment = .fill
    stackViewButtonContainer.distribution = .fillEqually
    
    stackViewButtonContainer.addArrangedSubview(buttonKorean)
    stackViewButtonContainer.addArrangedSubview(buttonTranslation)
    
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
      make.height.equalTo(50)
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
    setupNavBar()
  }
  
  func setupNavBar() {
    let searchBarItem = UIBarButtonItem(image: UIImage(named: IconName.search), style: .plain, target: self, action: #selector(openSearchController(sender:)))
    navigationItem.rightBarButtonItem = searchBarItem
    
    searchController.searchBar.placeholder = Strings.searchVocabOrTranslation
    searchController.hidesNavigationBarDuringPresentation = false
    
    searchController.searchBar.rx.text
    .orEmpty
    .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
    .distinctUntilChanged() // If they didn't occur, check if the new value is the same as old.
    .subscribe(onNext: { [weak self] string in
      if let vocabs = self?.viewModel.handleSearchBarTextInput(string) {
        self?.searchVocabListVM.setVocabs(vocabs)
      }
    })
    .disposed(by: disposeBag)
  }
  
  @objc private func openSearchController(sender: UIBarButtonItem) {
    present(searchController, animated: true, completion: nil)
  }
  
  private func observeViewModel() {
    
    viewModel.oScripts
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] scripts in
        guard let strongSelf = self else { return }
        
        strongSelf.viewControllers.removeAll()
        
        for script in scripts {
          let vm = ParagraphViewVM(script: script)
          let vc = ParagraphViewVC(viewModel: vm)
          strongSelf.viewControllers.append(vc)
        }
        
        guard strongSelf.viewControllers.count > 0 else { return }
        strongSelf.setupPageViewController(with: strongSelf.viewControllers)
        
        strongSelf.updateIndicatorView(leading: 0, width: strongSelf.view.frame.width / CGFloat(scripts.count))
      })
      .disposed(by: disposeBag)
    
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
  
  @objc private func handleButtonKoreanClicked(sender: UIButton) {
    guard viewControllers.count > 0 else { return }
    let vc = viewControllers[0]
    let direction: UIPageViewController.NavigationDirection = .reverse
    pageViewController.setViewControllers([vc], direction: direction, animated: true, completion: nil)
    updateIndicatorView(view: sender)
  }
  
  @objc private func handleButtonTranslationClicked(sender: UIButton) {
    guard viewControllers.count > 1 else { return }
    let vc = viewControllers[1]
    let direction: UIPageViewController.NavigationDirection = .forward
    pageViewController.setViewControllers([vc], direction: direction, animated: true, completion: nil)
    updateIndicatorView(view: sender)
  }
}

extension ParagraphVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
    guard viewControllers.count > 0 else { return }
    
    if let vc = pageViewController.viewControllers?.first,
      let index = indexOfViewController(vc) {
      currentVCIndex = index
      let width = self.view.frame.width / CGFloat(viewControllers.count)
      let leading = width * CGFloat(index)
      updateIndicatorView(leading: leading, width: width)
      print(index)
    }
  }
}

extension ParagraphVC {
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
