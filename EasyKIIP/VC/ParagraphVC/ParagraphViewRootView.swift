//
//  ParagraphViewRootView.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/15.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
import UIKit

class ParagraphViewRootView: NiblessView {
  
  private let viewModel: ParagraphViewVM
  private let disposeBag = DisposeBag()
  
  private let textViewScript = UITextView()
  
  init(viewModel: ParagraphViewVM,
       frame: CGRect = .zero) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    
    textViewScript.isEditable = false
    textViewScript.isSelectable = false
    
    addSubview(textViewScript)
    
    textViewScript.snp.makeConstraints { (make) in
      make.edges.equalToSuperview().inset(16)
    }
    
    viewModel.oScript
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] script in
        if let string = self?.createAttributedText(from: script) {
          self?.textViewScript.attributedText = string
        }
      })
    .disposed(by: disposeBag)
  }
  
  private func createAttributedText(from script: Script) -> NSAttributedString {

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    
    let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.appLabelBlack, .font: UIFont.appFontBold(ofSize: 25), .paragraphStyle: paragraphStyle]
    let scriptAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.appLabelBlack, .font: UIFont.appFontRegular(ofSize: 20)]

    let paragraph = NSMutableAttributedString(string: script.name + "\n\n", attributes: titleAttributes)
    let content = NSAttributedString(string: script.translation, attributes: scriptAttributes)

    paragraph.append(content)
    
    return paragraph
  }
  
}
