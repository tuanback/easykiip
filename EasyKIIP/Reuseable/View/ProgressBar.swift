//
//  ProgressBar.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import SnapKit

class ProgressBar: NiblessView {
  
  var progress: UInt8 = 0 {
    didSet {
      updateLayerFrame()
    }
  }
  
  private let viewTrack = UIView()
  private let viewForeground = UIView()
  
  override init(frame: CGRect = .zero) {
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    viewTrack.backgroundColor = UIColor.appSecondaryBackground
    viewForeground.backgroundColor = UIColor.appRed
    
    viewTrack.layer.cornerRadius = 10
    viewForeground.layer.cornerRadius = 10
    
    addSubview(viewTrack)
    addSubview(viewForeground)
    
    viewTrack.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    viewForeground.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.width.equalToSuperview().multipliedBy(CGFloat(progress) / 100)
    }
  }
  
  func updateLayerFrame() {
    viewForeground.snp.remakeConstraints { (make) in
      make.leading.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.width.equalToSuperview().multipliedBy(CGFloat(progress) / 100)
    }
  }
}
