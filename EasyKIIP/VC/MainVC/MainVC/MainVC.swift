//
//  MainVC.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EasyKIIPKit

class MainVC: NiblessViewController {
  
  private var buttonSetting: UIButton!
  
  private let viewModel: MainViewModel
  private let navigator: MainNavigator
  
  private let disposeBag = DisposeBag()
  private var imageSettingButton: UIImage? = UIImage(named: IconName.avatar)
  
  init(viewModel: MainViewModel,
       navigator: MainNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
  }
  
  override func loadView() {
    view = MainRootView(viewModel: viewModel)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavBar()
    observeViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.reload()
    setupMenuButton()
  }
  
  deinit {
    print("Deinit")
  }
  
  func setupNavBar() {
    navigationItem.title = "KIIP"
    
    let searchController = UISearchController(searchResultsController: nil)
    navigationItem.searchController = searchController
    
    //navigationController?.navigationBar.prefersLargeTitles = true
    /*
     let frame = CGRect(x: 0, y: 0, width: 300, height: 30)
     let titleView = UILabel(frame: frame)
     titleView.text = "Test"
     titleView.textColor = UIColor.appLabelColor
     navigationItem.titleView = titleView
     */
  }
  
  private func setupMenuButton() {
    buttonSetting?.removeFromSuperview()
    
    buttonSetting = UIButton()
    buttonSetting.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    buttonSetting.layer.cornerRadius = 0.5 * buttonSetting.bounds.size.width
    buttonSetting.setImage(imageSettingButton, for: .normal)
    buttonSetting.addTarget(self, action: #selector(handleSettingButtonClicked(_:)), for: .touchUpInside)
    let barButton = UIBarButtonItem()
    barButton.customView = buttonSetting
    self.navigationItem.rightBarButtonItem = barButton
  }
  
  @objc func handleSettingButtonClicked(_ barButton: UIBarButtonItem) {
    viewModel.handleSettingButtonClicked()
  }
  
  private func observeViewModel() {
    
    viewModel.oAvatarURL
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .subscribe(onNext: { [weak self] url in
        if let url = url,
          let data = try? Data(contentsOf: url),
          let image = UIImage(data: data) {
          let resizeImage = Common.resizeImage(image, newHeight: 30)
          self?.imageSettingButton = resizeImage
          DispatchQueue.main.async {
            self?.buttonSetting.setImage(resizeImage, for: .normal)
          }
        }
        else {
          let image = UIImage(named: IconName.avatar)
          DispatchQueue.main.async {
            self?.buttonSetting.setImage(image, for: .normal)
          }
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.oNavigation
      .subscribe(onNext: { [weak self] event in
        guard let strongSelf = self else { return }
        switch event {
        case .push(let destination):
          strongSelf.navigator.navigate(from: strongSelf, to: destination, type: .push)
        case .present(let destination):
          strongSelf.navigator.navigate(from: strongSelf, to: destination, type: .present)
        case .pop:
          self?.navigationController?.popViewController(animated: true)
        case .dismiss:
          self?.dismiss(animated: true, completion: nil)
        }
      })
      .disposed(by: disposeBag)
  }
  
}
