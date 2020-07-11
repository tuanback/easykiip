//
//  VocabListRootView.swift
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

class SubTitleTVC: UITableViewCell {
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: "SubTitleTVC")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class VocabListRootView: NiblessView {
  
  private lazy var tableView = UITableView()
  private let cellIdentifier = "SubTitleTVC"
  
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
    
    addSubview(tableView)
    
    tableView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    setupTableView()
  }
  
  private func setupTableView() {
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 100
    
    tableView.register(SubTitleTVC.self, forCellReuseIdentifier: cellIdentifier)
    
    viewModel.oListOfVocabsItemViewModels
      .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier)) { row, element, cell in
        
        cell.textLabel?.font = UIFont.appFontMedium(ofSize: 20)
        cell.textLabel?.text = element.word
        cell.detailTextLabel?.text = element.wordTranslation
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = UIFont.appFontRegular(ofSize: 18)
    }
    .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      })
    .disposed(by: disposeBag)
  }
  
}
