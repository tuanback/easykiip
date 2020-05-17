//
//  TutorialVC.swift
//  TutorialTemplate
//
//  Created by Tuan on 2019/12/27.
//  Copyright © 2019 3i. All rights reserved.
//

import UIKit

struct VideoTutorialItem {
  let videoURL: URL
  let header: String
  let message: String
}

class TutorialVC: UIPageViewController {
  
  static func storyboardInstance(tutorialItems: [VideoTutorialItem]) -> TutorialVC? {
    if let vc = UIStoryboard(name: String(describing: TutorialVC.self), bundle: nil).instantiateInitialViewController() as? TutorialVC {
      vc.mTutorialItems = tutorialItems
      return vc
    }
    return nil
  }
  
  private(set) lazy var orderedViewControllers: [UIViewController] = [UIViewController]()
  private var mCurrentViewController: UIViewController?
  private var pageControlWidthConstraint: NSLayoutConstraint!
  private var pageControlCenterXConstraint: NSLayoutConstraint!
  
  private var mTutorialItems: [VideoTutorialItem] = []
  
  //1 : member variable
  var pageControl = UIPageControl()
  
  @objc func canRotateAllButUpSideDown(){ }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setupViewControllers()
    setupPageControl()
    setupCloseButton()
    
    view.backgroundColor  = UIColor(hexString: "1976F4")
    dataSource            = self
    delegate              = self
    
    if let firstVC = orderedViewControllers.first {
      mCurrentViewController = firstVC
      setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    if UIDevice.current.orientation.isLandscape {
      pageControlWidthConstraint.isActive = true
      pageControlCenterXConstraint.isActive = false
    } else {
      pageControlWidthConstraint.isActive = false
      pageControlCenterXConstraint.isActive = true
    }
  }
  
}

extension TutorialVC {
  private func setupViewControllers() {
    for item in mTutorialItems {
      if let vc = TutorialItemVC.storyboardInstance(videoURL: item.videoURL, heading: item.header, message: item.message) {
        orderedViewControllers.append(vc)
      }
    }
  }
  
  // Call it from viewDidLoad
  func setupPageControl() {
    pageControl = UIPageControl()
    pageControl.numberOfPages  = mTutorialItems.count
    pageControl.currentPage    = 0
    pageControl.tintColor      = UIColor.lightGray
    pageControl.pageIndicatorTintColor = UIColor.lightGray
    pageControl.currentPageIndicatorTintColor = UIColor.white
    pageControl.backgroundColor = UIColor.clear
    view.addSubview(pageControl)
    
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
    pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    pageControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
    pageControlWidthConstraint = pageControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4)
    pageControlWidthConstraint.isActive = false
    
    pageControlCenterXConstraint = pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    pageControlCenterXConstraint.isActive = true
  }
  
  func setupCloseButton() {
    let closeButton = UIButton()
    closeButton.setImage(UIImage(named: ImageName.closeWhite), for: .normal)
    closeButton.addTarget(self, action: #selector(handleCloseButtonClicked(sender:)), for: .touchUpInside)
    self.view.addSubview(closeButton)
    
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
    closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    closeButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
    closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor).isActive = true
  }
  
  @objc private func handleCloseButtonClicked(sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: Navigate
extension TutorialVC {
  
  
  private func gotoNextSettingItem() {
    guard let vc = mCurrentViewController else { return }
    guard let nextVC = getNextVC(viewController: vc) else { return }
    mCurrentViewController = nextVC
    setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
  }
  
  private func getPreviousVC(viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }
    
    let previousIndex = viewControllerIndex - 1
    
    // User is on the first view controller and swiped left to loop to
    // the last view controller.
    guard previousIndex >= 0,
      orderedViewControllers.count > previousIndex else {
        return nil
    }
    
    return orderedViewControllers[previousIndex]
  }
  
  private func getNextVC(viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }
    
    let nextIndex                   = viewControllerIndex + 1
    let orderedViewControllersCount = orderedViewControllers.count
    
    guard orderedViewControllersCount != nextIndex,
      orderedViewControllersCount > nextIndex else {
        return nil
    }
    
    return orderedViewControllers[nextIndex]
  }
}

extension TutorialVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let vc = getPreviousVC(viewController: viewController) else {
      return nil
    }
    
    return vc
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let vc = getNextVC(viewController: viewController) else {
      return nil
    }
    
    return vc
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return }
    guard let vc = pageViewController.viewControllers?.first else { return }
    mCurrentViewController  = vc
    
    guard let viewControllerIndex = orderedViewControllers.firstIndex(of: vc) else { return }
    self.pageControl.currentPage  = viewControllerIndex
  }
  
  
}
