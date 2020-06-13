//
//  GeneralSetting.swift
//  pivo
//
//  Created by Tuan on 27/08/2019.
//  Copyright © 2019 Next Aeon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UserSession
import UIKit
import RxDataSources

struct TableViewSection {
  var header: String
  var items: [SettingItem]
}

extension TableViewSection: SectionModelType {
  typealias Item = SettingItem
  
  init(original: TableViewSection, items: [SettingItem]) {
    self = original
    self.items = items
  }
}

struct SettingVM {
  
  var oSections: Observable<[TableViewSection]> {
    return rSections.asObservable()
  }
  
  private var rSections = BehaviorRelay<[TableViewSection]>(value: [])
  
  private var sections: [SettingSection] = []
  
  init(userSessionRepository: UserSessionRepository) {
    var accountSettinsItems: [SettingItem] = []
    if userSessionRepository.readUserSession() == nil {
      accountSettinsItems = [.login]
    }
    else {
      accountSettinsItems = [.logOut]
    }
    
    sections.append(SettingSection(settingSectionItem: .account, settingItems: accountSettinsItems))
    sections.append(SettingSection(settingSectionItem: .language, settingItems: [.appLanguage]))
    
    let tableViewSections: [TableViewSection] = sections.map {
      return TableViewSection(header: $0.settingSectionItem.toString(),
                              items: $0.settingItems)
    }
    
    rSections.accept(tableViewSections)
  }
}
