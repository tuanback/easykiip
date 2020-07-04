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
  var sectionType: SettingSectionItem
  var items: [SettingItem]
}

extension TableViewSection: SectionModelType {
  typealias Item = SettingItem
  
  init(original: TableViewSection, items: [SettingItem]) {
    self = original
    self.items = items
  }
}

class SettingVM {
  
  var oSections: Observable<[TableViewSection]> {
    return rSections.asObservable()
  }
  
  private var rSections = BehaviorRelay<[TableViewSection]>(value: [])
  
  var oNavigation: Observable<NavigationEvent<SettingNavigator.Destination>> {
    return rNavigationEvent.asObservable()
  }
  
  private var rNavigationEvent = PublishRelay<NavigationEvent<SettingNavigator.Destination>>()
  
  private var sections: [SettingSection] = []
  private let userSessionRepo: UserSessionRepository
  
  init(userSessionRepository: UserSessionRepository) {
    self.userSessionRepo = userSessionRepository
  }
  
  func loadSettingItems() {
    sections.removeAll()
    var accountSettinsItems: [SettingItem] = []
    if userSessionRepo.readUserSession() == nil {
      accountSettinsItems = [.login, .premiumUpgrade]
    }
    else {
      accountSettinsItems = [.logOut, .premiumUpgrade]
    }
    
    sections.append(SettingSection(settingSectionItem: .account, settingItems: accountSettinsItems))
    sections.append(SettingSection(settingSectionItem: .language, settingItems: [.appLanguage]))
    
    let tableViewSections: [TableViewSection] = sections.map {
      return TableViewSection(header: $0.settingSectionItem.toString(),
                              sectionType: $0.settingSectionItem,
                              items: $0.settingItems)
    }
    
    rSections.accept(tableViewSections)
  }
  
  func handleSettingItemClicked(item: SettingItem) {
    switch item {
    case .login:
      rNavigationEvent.accept(.present(destination: .login(signedInResponder: nil)))
    case .logOut:
      userSessionRepo.signOut()
      loadSettingItems()
    case .appLanguage:
      rNavigationEvent.accept(.push(destination: .changeLanguage))
    case .premiumUpgrade:
      rNavigationEvent.accept(.present(destination: .payWall))
    }
  }
}
