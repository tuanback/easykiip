//
//  ChangeLanguageRootView.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/14.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import EasyKIIPKit
import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import UIKit

class ChangeLanguageRootView: NiblessView {
  
  private var viewModel: ChangeLanguageViewModel
  private let disposeBag = DisposeBag()
  
  private let tableView = UITableView(frame: .zero, style: .grouped)
  private let cellIdentifier = "CellIdentifier"
  
  private var lastSelected: IndexPath? = IndexPath(row: 0, section: 0)
  
  init(viewModel: ChangeLanguageViewModel,
       frame: CGRect = .zero) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    
    backgroundColor = UIColor.appBackground
    
    addSubview(tableView)
    
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(safeAreaInsets.top)
      make.bottom.equalTo(safeAreaInsets.bottom)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    let cellIdentifier = self.cellIdentifier
    
    let dataSource = RxTableViewSectionedReloadDataSource<LanguageSection>(configureCell: { [weak self] dataSource, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
      cell.textLabel?.text = item.toString()
      
      if AppSetting.languageCode == item {
        cell.accessoryType = .checkmark
        self?.lastSelected = indexPath
      }
      
      return cell
    })
    
    dataSource.titleForHeaderInSection = { dataSource, index in
      return ""
    }
    
    viewModel.oSections
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(LanguageCode.self)
      .subscribe(onNext: { [weak self] item in
        self?.viewModel.handleLanguageSelected(item)
      })
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if let i = self?.lastSelected, i != indexPath {
          self?.tableView.cellForRow(at: i)?.accessoryType = .none
          self?.lastSelected = nil
        }
      })
    .disposed(by: disposeBag)
    
    tableView.rx.itemDeselected
    .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.cellForRow(at: indexPath)?.accessoryType = .none
      })
    .disposed(by: disposeBag)
  }
}
