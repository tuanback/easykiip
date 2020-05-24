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
  
  let viewButtonContainer = UIView()
  let viewViewControllerContainer = UIView()
  
  let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                navigationOrientation: .horizontal,
                                                options: nil)
  var viewControllers: [UIViewController] = []
  var learnListVC: LearnVocabListVC?
  var readingListVC: ReadingListVC?
  var vocabListVC: VocabListVC?
  
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
    
    view.addSubview(viewButtonContainer)
    view.addSubview(viewViewControllerContainer)
    
    viewButtonContainer.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.equalTo(view.safeAreaLayoutGuide)
      make.trailing.equalTo(view.safeAreaLayoutGuide)
      make.height.equalTo(40)
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
    viewModel.childVC
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] childVCs in
        guard let strongSelf = self else { return }
        
        strongSelf.viewControllers.removeAll()
        
        for childVC in childVCs {
          switch childVC {
          case .learnVocab:
            strongSelf.learnListVC = LearnVocabListVC()
            strongSelf.viewControllers.append(strongSelf.learnListVC!)
          case .readingPart:
            strongSelf.readingListVC = ReadingListVC()
            strongSelf.viewControllers.append(strongSelf.readingListVC!)
          case .listOfVocabs:
            strongSelf.vocabListVC = VocabListVC()
            strongSelf.viewControllers.append(strongSelf.vocabListVC!)
          }
        }
        
        guard strongSelf.viewControllers.count > 0 else { return }
        strongSelf.setupPageViewController(with: strongSelf.viewControllers)
      })
      .disposed(by: disposeBag)
  }
  
  private func setupPageViewController(with viewControllers: [UIViewController]) {
    pageViewController.delegate = self
    pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: true, completion: nil)
    pageViewController.dataSource = self
    
    addChild(pageViewController)
    viewViewControllerContainer.addSubview(pageViewController.view)
    
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
