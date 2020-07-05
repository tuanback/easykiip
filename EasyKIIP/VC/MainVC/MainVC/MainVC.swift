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
import Firebase
import SnapKit

class MainVC: NiblessViewController {
  
  private var buttonSetting: UIButton!
  
  private let viewModel: MainViewModel
  private let navigator: MainNavigator
  
  private let disposeBag = DisposeBag()
  private var imageSettingButton: UIImage? = UIImage(named: IconName.avatar)
  
  private lazy var searchVocabListVM = SearchVocabListViewModel(vocabs: [])
  private lazy var searchVocabListVC = SearchVocabListVC(viewModel: searchVocabListVM)
    
  private lazy var bannerView = GADBannerView(adSize: kGADAdSizeBanner)
  
  init(viewModel: MainViewModel,
       navigator: MainNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
  }
  
  override func loadView() {
    view = MainRootView(viewModel: viewModel)
    setupBannerLayout()
  }
  
  private func setupBannerLayout() {
    if viewModel.shouldLoadAds() {
      view.addSubview(bannerView)
      bannerView.snp.makeConstraints { (make) in
        make.bottom.equalTo(view.safeAreaLayoutGuide)
        make.centerX.equalToSuperview()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavBar()
    observeViewModel()
    loadAds()
  }
  
  private func loadAds() {
    if viewModel.shouldLoadAds() {
      bannerView.adUnitID = AdsIdentifier.id(for: .banner)
      bannerView.rootViewController = self
      bannerView.load(GADRequest())
    }
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
    
    let searchController = UISearchController(searchResultsController: searchVocabListVC)
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = Strings.searchVocabOrTranslation
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
    buttonSetting.layer.cornerRadius = 15
    buttonSetting.layer.masksToBounds = true
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

extension MainVC: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    if let text = searchBar.text {
      let vocabs = viewModel.handleSearchBarTextInput(text)
      searchVocabListVM.setVocabs(vocabs)
    }
  }
}
