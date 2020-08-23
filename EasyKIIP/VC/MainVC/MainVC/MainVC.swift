//
//  MainVC.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

//import AdSupport
//import AppTrackingTransparency
import AVKit
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
  private lazy var updateChecker = UpdateChecker()
  
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
    checkForUpdate()
  }
  
  private func loadAds() {
    if viewModel.shouldLoadAds() {
      bannerView.adUnitID = AdsIdentifier.id(for: .banner)
      bannerView.rootViewController = self
      let request = GADRequest()
      bannerView.load(request)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.reload()
    setupMenuButton()
    removeBannerIfNeeded()
  }
  
  private func removeBannerIfNeeded() {
    if !viewModel.shouldLoadAds() {
      bannerView.removeFromSuperview()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    showPopUpToAskUserForAllowingTracking()
    playHowToUseVideoIfNotShowed()
  }
  
  private func playHowToUseVideoIfNotShowed() {
    if !AppValuesStorage.isHowToUseTheAppShowed {
      switch AppSetting.languageCode {
      case .en:
        guard let url = Bundle.main.url(forResource: "en", withExtension: "mov") else { return }
        playVideo(url: url)
        AppValuesStorage.isHowToUseTheAppShowed = true
      case .vi:
        guard let url = Bundle.main.url(forResource: "vi", withExtension: "mov") else { return }
        playVideo(url: url)
        AppValuesStorage.isHowToUseTheAppShowed = true
      }
    }
  }
  
  private func playVideo(url: URL) {
    try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
    let player = AVPlayer(url: url)
    player.volume = 0.5
    let vc = AVPlayerViewController()
    vc.player = player
    
    present(vc, animated: true, completion: {
      player.play()
    })
  }
  
  private func showPopUpToAskUserForAllowingTracking() {
    loadAds()
    /*
    if #available(iOS 14, *) {
      if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
        presentAlert(title: Strings.pleaseTapAllowTrackingOnTheNextScreen,
                     message: Strings.allowTrackingExplaination,
                     cancelActionText: Strings.notNow,
                     confirmActionText: Strings.later) {
          self.requestIDFA()
        }
      }
    } else {
      loadAds()
    }
    */
  }
  
  /*
  @available(iOS 14, *)
  private func requestIDFA() {
    ATTrackingManager.requestTrackingAuthorization(completionHandler: { [weak self] status in
      switch status {
      case .authorized:
        self?.loadAds()
      default:
        break
      }
    })
  }
  */
  
  private func checkForUpdate() {
    updateChecker.isUpdateAvailable { [weak self] (isAvailable) in
      guard let strongSelf = self else { return }
      if isAvailable {
        strongSelf.updateChecker.showUpdatePopUp(target: strongSelf)
      }
    }
  }
  
  deinit {
    print("Deinit")
  }
  
  func setupNavBar() {
    navigationItem.title = "KIIP"
    
    let searchController = UISearchController(searchResultsController: searchVocabListVC)
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
    // Save practice history if the app move to background
    UIApplication.shared.rx.applicationDidEnterBackground
      .subscribe(onNext: { [weak self] _ in
        self?.viewModel.handleFinishLearning()
      })
      .disposed(by: disposeBag)
    
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
