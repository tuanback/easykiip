//
//  MainBookItemCVC.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/02.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit

class MainBookItemCVC: UICollectionViewCell {
  
  private var viewModel: BookItemViewModel?
  
  var containerView: UIView!
  var imageView: UIImageView!
  var labelBookName: UILabel!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Setup Views
  private func setupViews() {
    
    containerView = UIView()
    containerView.layer.cornerRadius = 10
    containerView.layer.shadowColor = UIColor.appShadowColor.cgColor
    containerView.layer.shadowRadius = 5
    containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
    containerView.layer.shadowOpacity = 0.8
    addSubview(containerView)
    
    imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 10
    imageView.layer.masksToBounds = true
    containerView.addSubview(imageView)
    
    labelBookName = UILabel()
    labelBookName.font = UIFont.appFontMedium(ofSize: 15)
    labelBookName.numberOfLines = 2
    labelBookName.adjustsFontSizeToFitWidth = true
    labelBookName.minimumScaleFactor = 0.5
    labelBookName.textAlignment = .center
    labelBookName.textColor = UIColor.appLabelBlack
    addSubview(labelBookName)
    
    labelBookName.snp.makeConstraints { (make) in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.bottom.equalTo(self)
      make.height.equalTo(40)
    }
    
    containerView.snp.makeConstraints { (make) in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(self)
      make.bottom.equalTo(labelBookName.snp.top).offset(-8)
    }
    
    imageView.snp.makeConstraints { (make) in
      make.top.equalTo(containerView).offset(5)
      make.bottom.equalTo(containerView).offset(-5)
      make.centerX.equalTo(self)
      make.width.equalTo(imageView.snp.height).multipliedBy(0.75)
    }
  }
  
  func configCell(viewModel: BookItemViewModel) {
    self.viewModel = viewModel
    if let imageURL = viewModel.thumbURL,
      let data = try? Data(contentsOf: imageURL),
      let image = UIImage(data: data) {
      self.imageView.image = image
    }
    
    labelBookName.text = viewModel.name
  }
  
}
