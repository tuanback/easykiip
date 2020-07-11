//
//  QuizVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/07.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
import Firebase
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
  private var practiceVC: QuizPracticeVC?
  private var practiceVM: QuizPracticeViewModel?
  
  private lazy var nativeAdUnitID = AdsIdentifier.id(for: .nativeAds)
  private lazy var nativeAdLoader = NativeAdLoader(adUnitID: nativeAdUnitID,
                                                   numberOfAdsToLoad: 1,
                                                   viewController: self,
                                                   delegate: self)
  
  private lazy var rewardAdUnitID = AdsIdentifier.id(for: .rewardVideo)
  private lazy var rewardAdLoader = RewardAdLoader(adUnitID: rewardAdUnitID,
                                                   delegate: self)
  
  private lazy var rewardInterstitialAdLoader = InterstitialAdLoader(adUnitID: AdsIdentifier.id(for: .interstitial), delegate: self)
  
  private var player: AVAudioPlayer?
  private var didShowVideoAds = false
  
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
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    hideNavBar()
    loadAds()
    observeViewModel()
  }
  
  private func loadAds() {
    if viewModel.shouldLoadAds() {
      nativeAdLoader.load()
      rewardAdLoader.load()
      rewardInterstitialAdLoader.load()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    showHeartFilledToastIfNeeded()
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
          strongSelf.practiceVC = nil
          strongSelf.pageViewController
            .setViewControllers([strongSelf.newWordVC!], direction: .forward,
                                animated: true, completion: nil)
        case .practice(let viewModel):
          // NOTE: If current vc is practive vc => reuse
          if let _ = strongSelf.practiceVC,
            let practiceVM = strongSelf.practiceVM {
            practiceVM.updateViewModel(quizItemViewModel: viewModel)
          }
          else {
            let vm = QuizPracticeViewModel(quizItemViewModel: viewModel, answerHandler: strongSelf.viewModel)
            strongSelf.practiceVM = vm
            strongSelf.practiceVC = QuizPracticeVC(viewModel: vm)
            strongSelf.pageViewController
              .setViewControllers([strongSelf.practiceVC!], direction: .forward,
                                  animated: true, completion: nil)
            
            vm.oPlaySound
              .observeOn(MainScheduler.asyncInstance)
              .subscribe(onNext: { [weak self] sound in
                let url = sound.url
                self?.playSound(url: url)
              })
              .disposed(by: strongSelf.disposeBag)
          }
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.oHeartViewHidden
      .drive(stackViewHeart.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel.oHeart
      .observeOn(MainScheduler.asyncInstance)
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
          switch destination {
          case .showVideoAds:
            self?.showVideoAds()
          default:
            self?.navigator.navigate(from: strongSelf, to: destination, type: .present)
          }
        case .push(let destination):
          switch destination {
          case .showVideoAds:
            self?.showVideoAds()
          default:
            self?.navigator.navigate(from: strongSelf, to: destination, type: .push)
          }
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func showVideoAds() {
    let present = rewardAdLoader.present(viewController: self)
    if !present {
      let presentInterstitial = rewardInterstitialAdLoader.present(viewController: self)
      if !presentInterstitial {
        self.viewModel.handleCannotPresentVideo()
      }
    }
  }
  
  private func showAlertMessage(alert: AlertWithAction) {
    let alertMessage = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
    alertMessage.view.tintColor = UIColor.appRed
    
    for action in alert.actions {
      let alertAction = UIAlertAction(title: action.title, style: action.style) { (_) in
        action.handler()
      }
      alertMessage.addAction(alertAction)
    }
    
    present(alertMessage, animated: true, completion: nil)
  }
  
  func playSound(url: URL) {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
      
      player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
      
      guard let player = player else { return }
      
      player.play()
      
    } catch let error {
      print(error.localizedDescription)
    }
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
      make.height.equalTo(30)
      make.width.equalTo(0)
    }
    
    viewViewControllerContainer.snp.makeConstraints { (make) in
      make.top.equalTo(buttonClose.snp.bottom).offset(16)
      make.bottom.equalTo(view.safeAreaInsets.bottom).offset(-16)
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
  }
  
  private func setupStackViewHeart(numberOfHeart: Int, totalHeart: Int) {
    stackViewHeart.snp.updateConstraints({ (make) in
      make.width.equalTo(30 * totalHeart)
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

extension QuizVC: NativeAdLoaderDelegate {
  func adLoaderFinishLoading(ads: [GADUnifiedNativeAd]) {
    if ads.count > 0 {
      viewModel.setEndQuizAd(ad: ads[0])
    }
  }
}

extension QuizVC: RewardAdLoaderDelegate {
  func rewardAdLoader(userDidEarn reward: GADAdReward) {
    viewModel.handleVideoAdsWatchingFinished()
    didShowVideoAds = true
  }
  
  func showHeartFilledToastIfNeeded() {
    if didShowVideoAds {
      view.makeToast(Strings.heartsAreRefilled, duration: 1.5, position: .bottom)
      didShowVideoAds = false
    }
  }
}

extension QuizVC: InterstitialAdLoaderDelegate {
  func interstitialAdLoaderDidClose() {
    viewModel.handleVideoAdsWatchingFinished()
    didShowVideoAds = true
  }
  
  func interstitialAdLoaderDidReceiveAd() {
    
  }
}
