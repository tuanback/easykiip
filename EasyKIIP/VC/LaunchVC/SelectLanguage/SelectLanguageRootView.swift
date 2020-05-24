//
//  SelectLanguageRootView.swift
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
import EasyKIIPKit

class SelectLanguageRootView: NiblessView {
  
  struct Language {
    let image: UIImage
    let name: String
    let languageCode: LanguageCode
  }
  
  private let disposeBag = DisposeBag()
  
  private var collectionView: UICollectionView!
  private var collectionViewFlowLayout: UICollectionViewFlowLayout!
  private let cellIdentifier = "LanguageCVC"
  
  private let viewContainer = UIView()
  private let labelSelectLanguage = UILabel()
  
  private let didLanguageSelected: (Language)->()
  
  init(frame: CGRect = .zero,
       didLanguageSelected: @escaping (Language)->()) {
    self.didLanguageSelected = didLanguageSelected
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    
    backgroundColor = UIColor.systemGray.withAlphaComponent(0.8)
    
    viewContainer.backgroundColor = UIColor.appBackground
    viewContainer.layer.cornerRadius = 15
    viewContainer.layer.masksToBounds = true
    
    labelSelectLanguage.textColor = UIColor.appLabelBlack
    labelSelectLanguage.font = UIFont.appFontMedium(ofSize: 18)
    labelSelectLanguage.textAlignment = .center
    labelSelectLanguage.text = "Select your language"
    
    collectionViewFlowLayout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
    collectionView.backgroundColor = UIColor.clear
    collectionView.delegate = self
    
    addSubview(viewContainer)
    
    viewContainer.addSubview(labelSelectLanguage)
    viewContainer.addSubview(collectionView)
    
    viewContainer.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      make.width.equalToSuperview().multipliedBy(0.8)
      make.height.equalTo(180)
    }
    
    labelSelectLanguage.snp.makeConstraints { (make) in
      make.top.equalToSuperview().inset(16)
      make.leading.equalToSuperview().inset(20)
      make.trailing.equalToSuperview().inset(20)
    }
    
    collectionView.snp.makeConstraints { (make) in
      make.top.equalTo(labelSelectLanguage.snp.bottom).offset(16)
      make.bottom.equalToSuperview().inset(16)
      make.leading.equalToSuperview().inset(20)
      make.trailing.equalToSuperview().inset(20)
    }
    
    collectionView.register(LanguageCVC.self, forCellWithReuseIdentifier: cellIdentifier)
    
    Observable<[Language]>.just(
      [Language(image: UIImage(named: "vietnam")!, name: "Tiếng Việt", languageCode: .vi),
       Language(image: UIImage(named: "uk")!, name: "English", languageCode: .en)])
      .bind(to: collectionView.rx.items(cellIdentifier: cellIdentifier, cellType: LanguageCVC.self)) { row, viewModel, cell in
        cell.configCell(flagImage: viewModel.image, languageName: viewModel.name)
    }
    .disposed(by: disposeBag)
    
    collectionView.rx
      .modelSelected(Language.self)
      .subscribe(onNext: { [weak self] language in
        self?.didLanguageSelected(language)
      })
    .disposed(by: disposeBag)
  }
  
}

extension SelectLanguageRootView: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 16
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (collectionView.frame.width - 16) / 2
    let height = collectionView.frame.height
    return CGSize(width: width, height: height)
  }
  
}

private class LanguageCVC: UICollectionViewCell {
  
  private var stackView: UIStackView = {
    let sv = UIStackView()
    sv.axis = .vertical
    sv.alignment = .fill
    sv.distribution = .fill
    sv.spacing = 5
    return sv
  }()
  
  private var viewFlagContainer = UIView()
  
  private var ivFlag: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    return iv
  }()
  
  private var labelFlagName: UILabel = {
    let lb = UILabel()
    lb.font = UIFont.appFontRegular(ofSize: 15)
    lb.textAlignment = .center
    lb.textColor = UIColor.appLabelBlack
    return lb
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews() {
    
    addSubview(stackView)
    
    stackView.addArrangedSubview(viewFlagContainer)
    stackView.addArrangedSubview(labelFlagName)
    
    viewFlagContainer.addSubview(ivFlag)
    
    stackView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    labelFlagName.snp.makeConstraints { (make) in
      make.height.equalTo(22)
    }
    
    ivFlag.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      make.height.equalToSuperview().multipliedBy(0.8)
      make.width.equalTo(viewFlagContainer.snp.height).multipliedBy(0.8)
    }
  }
  
  func configCell(flagImage: UIImage, languageName: String) {
    ivFlag.image = flagImage
    labelFlagName.text = languageName
  }
}
