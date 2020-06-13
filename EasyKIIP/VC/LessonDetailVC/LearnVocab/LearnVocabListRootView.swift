//
//  LearnVocabListRootView.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class VocabCollectionCVC: UICollectionViewCell {
  
  private let containerView = UIView()
  private let labelIndex = UILabel()
  private let viewProgress = ProgressBar()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews() {
    
    backgroundColor = UIColor.appSecondaryBackground
    
    containerView.backgroundColor = UIColor.appSecondaryBackground
    containerView.layer.cornerRadius = 10
    containerView.layer.shadowColor = UIColor.appShadowColor.cgColor
    containerView.layer.shadowRadius = 3
    containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
    containerView.layer.shadowOpacity = 0.8
    addSubview(containerView)
    
    labelIndex.font = UIFont.appFontDemiBold(ofSize: 25)
    labelIndex.textAlignment = .center
    
    containerView.addSubview(labelIndex)
    containerView.addSubview(viewProgress)
    
    containerView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    labelIndex.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
    }
    
    viewProgress.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(8)
      make.trailing.equalToSuperview().inset(8)
      make.bottom.equalToSuperview().inset(8)
      make.height.equalTo(18)
    }
  }
  
  func configCell(viewModel: LearnVocabItemViewModel) {
    labelIndex.text = "\(viewModel.index)"
    viewProgress.progress = viewModel.proficiency
  }
  
}

class LearnVocabListRootView: NiblessView {
  
  private var collectionView: UICollectionView!
  private lazy var collectionViewFlowLayout = UICollectionViewFlowLayout()
  private let interItemSpacing: CGFloat = 20
  private let lineSpacing: CGFloat = 20
  private let cellIdentifier = "VocabCollectionCVC"
  
  private let disposeBag = DisposeBag()
  
  private let viewModel: LessonDetailViewModel
  
  init(frame: CGRect = .zero,
       viewModel: LessonDetailViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    backgroundColor = UIColor.appBackground
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
    collectionView.layer.masksToBounds = false
    collectionView.backgroundColor = UIColor.appBackground
    collectionView.delegate = self
    
    addSubview(collectionView)
    
    collectionView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview().inset(16)
    }
    
    collectionView.register(VocabCollectionCVC.self, forCellWithReuseIdentifier: cellIdentifier)
    
    viewModel.oLearnVocabVItemiewModels.bind(to: collectionView.rx.items(cellIdentifier: cellIdentifier, cellType: VocabCollectionCVC.self)) { row, viewModel, cell in
      cell.configCell(viewModel: viewModel)
    }
    .disposed(by: disposeBag)
    
    collectionView.rx.modelSelected(LearnVocabItemViewModel.self)
      .subscribe(onNext: { [weak self] itemViewModel in
        self?.viewModel.handleItemViewModelClicked(viewModel: itemViewModel)
      })
      .disposed(by: disposeBag)
  }
  
}

extension LearnVocabListRootView: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return interItemSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return lineSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let numberOfItemsPerRow: CGFloat = 3
    
    let width = (collectionView.frame.width - (numberOfItemsPerRow - 1) * interItemSpacing) / numberOfItemsPerRow
    let height = width * 1.2
    return CGSize(width: width, height: height)
  }
  
}
