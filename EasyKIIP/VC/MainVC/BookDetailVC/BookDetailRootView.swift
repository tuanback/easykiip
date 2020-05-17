//
//  BookDetailRootView.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/12.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BookDetailRootView: NiblessView {
  
  private let viewModel: BookDetailViewModel
  
  private let disposeBag = DisposeBag()
  
  private var collectionView: UICollectionView!
  private var collectionViewFlowLayout: UICollectionViewFlowLayout!
  
  private let bookDetailIdentifier = "BookDetailCVC"
  private let adsIdentifier = "BookDetailAdsCVC"
  
  init(frame: CGRect = .zero,
       viewModel: BookDetailViewModel) {
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
      make.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
    }
    
    collectionView.register(BookDetailCVC.self, forCellWithReuseIdentifier: bookDetailIdentifier)
    collectionView.register(BookDetailAdsCVC.self, forCellWithReuseIdentifier: adsIdentifier)
    
    let bookDetailIdentifier = self.bookDetailIdentifier
    let adsIdentifier = self.adsIdentifier
    viewModel.itemViewModels.bind(to: collectionView.rx.items) { collectionView, index, itemViewModel in
      
      switch itemViewModel {
      case .item(let viewModel):
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bookDetailIdentifier, for: IndexPath(item: index, section: 0)) as! BookDetailCVC
        cell.configCell(viewModel: viewModel)
        return cell
      case .ads(let viewModel):
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: adsIdentifier, for: IndexPath(item: index, section: 0)) as! BookDetailAdsCVC
        cell.configCell(viewModel)
        return cell
      }
    }
    .disposed(by: disposeBag)
    
    collectionView.rx.modelSelected(BookDetailItemViewModel.self)
      .subscribe(onNext: { [weak self] viewModel in
        switch viewModel {
        case .item(let itemViewModel):
          self?.viewModel.handleViewModelSelected(itemVM: itemViewModel)
        default:
          break
        }
      })
    .disposed(by: disposeBag)
  }
}

extension BookDetailRootView: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 8
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.frame.width
    let height: CGFloat = 130
    return CGSize(width: width, height: height)
  }
  
}
