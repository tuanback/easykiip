//
//  BookDetailVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleMobileAds
import RxSwift
import RxCocoa
import SVProgressHUD

public class BookDetailVC: NiblessViewController {
  
  private let viewModel: BookDetailViewModel
  private let navigator: BookDetailNavigator
  
  private lazy var adUnitID = AdsIdentifier.id(for: .onlyImageNativeAds)
  private var adLoader: NativeAdLoader?
  private var numAdsToLoad: Int = 4
  
  private let disposeBag = DisposeBag()
  
  private lazy var searchVocabListVM = SearchVocabListViewModel(vocabs: [])
  private lazy var searchVocabListVC = SearchVocabListVC(viewModel: searchVocabListVM)
  
  private var isVCJustEntering = true
  
  init(viewModel: BookDetailViewModel,
       navigator: BookDetailNavigator) {
    self.viewModel = viewModel
    self.navigator = navigator
    super.init()
  }
  
  public override func loadView() {
    view = BookDetailRootView(viewModel: viewModel)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupNavBar()
    observeViewModel()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if isVCJustEntering {
      isVCJustEntering = false
    }
    else {
      viewModel.reload()
    }
  }
  
  func setupNavBar() {
    let searchController = UISearchController(searchResultsController: searchVocabListVC)
    searchController.searchBar.placeholder = Strings.searchVocabOrTranslation
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    
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
  
  private func observeViewModel() {
    UIApplication.shared.rx.applicationDidEnterBackground
    .subscribe(onNext: { [weak self] _ in
      self?.viewModel.handleFinishLearning()
    })
    .disposed(by: disposeBag)
    
    viewModel.oNavigationTitle
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { isLoading in
        if isLoading {
          SVProgressHUD.show()
        }
        else {
          SVProgressHUD.dismiss()
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
          strongSelf.navigationController?.popViewController(animated: true)
        case .dismiss:
          strongSelf.dismiss(animated: true, completion: nil)
        }
      })
    .disposed(by: disposeBag)
    
    viewModel.oNumberOfLessons
      .subscribe(onNext: { [weak self] count in
        guard count > 0 else { return }
        let numAdsToLoad = count / 5
        self?.numAdsToLoad = numAdsToLoad
        self?.initAndStartAdLoader(numberOfItems: numAdsToLoad)
      })
      .disposed(by: disposeBag)
    
    InternetStateProvider
    .shared
    .oInternetConnectionState
    .skip(1)
    .distinctUntilChanged()
      .subscribe(onNext: { [weak self] isConnected in
        guard let strongSelf = self, let adLoader = strongSelf.adLoader else { return }
        if isConnected, !adLoader.isAdsReceived {
          self?.initAndStartAdLoader(numberOfItems: strongSelf.numAdsToLoad)
        }
      })
    .disposed(by: disposeBag)
  }
  
  private func initAndStartAdLoader(numberOfItems: Int) {
    guard viewModel.shouldLoadAds() else { return }
    
    adLoader = NativeAdLoader(adUnitID: adUnitID,
                              numberOfAdsToLoad: numberOfItems,
                              viewController: self,
                              delegate: self)
    startAdLoader()
  }
  
  private func startAdLoader() {
    adLoader?.load()
  }
}

extension BookDetailVC: NativeAdLoaderDelegate {
  func adLoaderFinishLoading(ads: [GADUnifiedNativeAd]) {
    viewModel.addNativeAds(ads: ads)
  }
}
