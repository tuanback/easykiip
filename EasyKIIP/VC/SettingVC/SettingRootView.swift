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
  
  private var viewModel: SettingVM
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
    
    addSubview(tableView)
    
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(safeAreaInsets.top)
      make.bottom.equalTo(safeAreaInsets.bottom)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    let cellIdentifier = self.cellIdentifier
    
    let dataSource = RxTableViewSectionedReloadDataSource<TableViewSection>(configureCell: { dataSource, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
      cell.textLabel?.text = item.toString()
      switch item {
      case .appLanguage:
        cell.accessoryType = .disclosureIndicator
        switch AppSetting.languageCode {
        case .en:
          cell.detailTextLabel?.text = Strings.english
        case .vi:
          cell.detailTextLabel?.text = Strings.vietnamese
        }
      case .contactUs, .rateUs:
        cell.accessoryType = .disclosureIndicator
      case .login, .logOut, .premiumUpgrade:
        break
      }
      return cell
    })
    
    dataSource.titleForHeaderInSection = { dataSource, index in
      return dataSource.sectionModels[index].header
    }
    
    dataSource.titleForFooterInSection = { dataSource, index in
      return dataSource.sectionModels[index].footer
    }
    
    viewModel.oSections
    .debug()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(SettingItem.self)
      .subscribe(onNext: { [weak self] item in
        self?.viewModel.handleSettingItemClicked(item: item)
      })
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      })
    .disposed(by: disposeBag)
  }
  
}
