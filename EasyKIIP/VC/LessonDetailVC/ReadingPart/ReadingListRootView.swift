//
//  ReadingListRootView.swift
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

class ReadingListRootView: NiblessView {
  
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
    tableView.estimatedRowHeight = 80
    
    tableView.alwaysBounceVertical = false
    
    tableView.register(SubTitleTVC.self, forCellReuseIdentifier: cellIdentifier)
    
    viewModel.oReadingPartItemViewModels
      .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier)) { row, element, cell in
        cell.textLabel?.font = UIFont.appFontMedium(ofSize: 16)
        cell.textLabel?.text = element.scriptName
        cell.detailTextLabel?.text = element.scriptNameTranslation
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = UIFont.appFontRegular(ofSize: 13)
        cell.accessoryType = .disclosureIndicator
    }
    .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      })
    .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(ReadingPartItemViewModel.self)
      .subscribe(onNext: { [weak self] model in
        print(model)
      })
    .disposed(by: disposeBag)
  }
  
  
}
