//
//  MainRootView.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MainRootView: NiblessView {
  
  private let viewModel: MainViewModel
  
  private var collectionView: UICollectionView!
  private var collectionViewFlowLayout: UICollectionViewFlowLayout!
  
  private let cellIdentifier = "MainBookItemCVC"
  
  private let disposeBag = DisposeBag()
  
  init(frame: CGRect = .zero,
       viewModel: MainViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    backgroundColor = UIColor.appBackground
    setupCollectionViews()
  }
  
  private func setupCollectionViews() {
    collectionViewFlowLayout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
    collectionView.layer.masksToBounds = false
    collectionView.backgroundColor = UIColor.appBackground
    collectionView.delegate = self
    
    addSubview(collectionView)
    
    collectionView.snp.makeConstraints { (make) in
      make.top.equalTo(safeAreaLayoutGuide).offset(16)
      make.leading.equalTo(safeAreaLayoutGuide).offset(16)
      make.trailing.equalTo(safeAreaLayoutGuide).offset(-16)
      make.bottom.equalTo(safeAreaLayoutGuide)
    }
    
    collectionView.register(MainBookItemCVC.self, forCellWithReuseIdentifier: cellIdentifier)
    
    viewModel.bookViewModels.bind(to: collectionView.rx.items(cellIdentifier: cellIdentifier, cellType: MainBookItemCVC.self)) {row, itemViewModel, cell in
      cell.configCell(viewModel: itemViewModel)
    }
    .disposed(by: disposeBag)
  }
  
}

extension MainRootView: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 16
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (collectionView.frame.width - 16) / 2
    let height = width * 4 / 3
    return CGSize(width: width, height: height)
  }
  
}
