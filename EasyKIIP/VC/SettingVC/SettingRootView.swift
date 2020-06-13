//
//  SettingRootView.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import UIKit

class SettingRootView: NiblessView {
  
  private let viewModel: SettingVM
  private let disposeBag = DisposeBag()
  
  private let tableView = UITableView(frame: .zero, style: .grouped)
  private let cellIdentifier = "CellIdentifier"
  
  init(viewModel: SettingVM,
       frame: CGRect = .zero) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
  }
  
  private func setupViews() {
    
    backgroundColor = UIColor.appBackground
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    
    addSubview(tableView)
    
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(safeAreaInsets.top)
      make.bottom.equalTo(safeAreaInsets.bottom)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    let cellIdentifier = self.cellIdentifier
    
    let dataSource = RxTableViewSectionedReloadDataSource<TableViewSection>(configureCell: { dataSource, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
      cell.textLabel?.text = item.toString()
      return cell
    })
    
    dataSource.titleForHeaderInSection = { dataSource, index in
      return dataSource.sectionModels[index].header
    }
    
    viewModel.oSections
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
  
}
