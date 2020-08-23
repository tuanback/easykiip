//
//  SettingVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import AVKit
import Foundation
import RxSwift
import RxCocoa
import UIKit

class SettingVC: NiblessViewController {
  
  private var viewModel: SettingVM
  private var navigator: SettingNavigator

  private let disposeBag = DisposeBag()

  private lazy var emailSender = EmailSender()
  
  init(viewModel: SettingVM, navigator: SettingNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
  }
  
  override func loadView() {
    view = SettingRootView(viewModel: viewModel)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.loadSettingItems()
    setupNavBar()
  }
  
  private func setupNavBar() {
    navigationItem.title = Strings.settings
    
    let doneButton = UIBarButtonItem(title: Strings.done, style: .done, target: self, action: #selector(handleDoneButtonClicked(_:)))
    doneButton.tintColor = UIColor.appRed
    navigationItem.rightBarButtonItem = doneButton
  }
  
  @objc func handleDoneButtonClicked(_ barButton: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func observeViewModel() {
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
    
    viewModel.oSendMail
      .subscribe(onNext: { [weak self] _ in
        guard let strongSelf = self else { return }
        strongSelf.emailSender.sendEmail(parentController: strongSelf, subject: Strings.feedBack, content: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel.oPlayHowToUseVideo
      .subscribe(onNext: { [weak self] _ in
        self?.playHowToUseVideoIfNotShowed()
      })
      .disposed(by: disposeBag)
  }
  
  private func playHowToUseVideoIfNotShowed() {
    switch AppSetting.languageCode {
    case .en:
      guard let url = Bundle.main.url(forResource: "en", withExtension: "mov") else { return }
      playVideo(url: url)
    case .vi:
      guard let url = Bundle.main.url(forResource: "vi", withExtension: "mov") else { return }
      playVideo(url: url)
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
  
}
