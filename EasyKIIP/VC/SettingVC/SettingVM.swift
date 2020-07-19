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
import StoreKit

struct TableViewSection {
  var header: String
  var sectionType: SettingSectionItem
  var items: [SettingItem]
  var footer: String
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
  
  var oSendMail: Observable<Void> {
    return rSendEmail.asObservable()
  }
  var rSendEmail = PublishRelay<Void>()
  
  private var sections: [SettingSection] = []
  private let userSessionRepo: UserSessionRepository
  
  init(userSessionRepository: UserSessionRepository) {
    self.userSessionRepo = userSessionRepository
  }
  
  func loadSettingItems() {
    sections.removeAll()
    let isSubscribedUser = userSessionRepo.isUserSubscribed()
    let isUserLoggedIn = (userSessionRepo.readUserSession() != nil)
    var accountSettinsItems: [SettingItem] = []
    
    if isUserLoggedIn {
      accountSettinsItems = [.logOut]
    }
    else {
      accountSettinsItems = [.login]
    }
    
    if !isSubscribedUser {
      accountSettinsItems.append(.premiumUpgrade)
    }
    
    sections.append(SettingSection(settingSectionItem: .account, settingItems: accountSettinsItems))
    sections.append(SettingSection(settingSectionItem: .language, settingItems: [.appLanguage]))
    sections.append(SettingSection(settingSectionItem: .support, settingItems: [.rateUs, .contactUs]))
    
    let tableViewSections: [TableViewSection] = sections.map {
      
      var footer = ""
      
      switch $0.settingSectionItem {
      case .account:
        if isSubscribedUser && !isUserLoggedIn {
          footer = Strings.accountExplaination
        }
      default:
        break
      }
      
      return TableViewSection(header: $0.settingSectionItem.toString(),
                              sectionType: $0.settingSectionItem,
                              items: $0.settingItems,
                              footer: footer)
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
    case .contactUs:
      rSendEmail.accept(())
    case .rateUs:
      rateApp()
    }
  }
  
  private func rateApp(appId: String = "id1521739580") {
    openUrl("itms-apps://itunes.apple.com/app/" + appId)
  }
  
  private func openUrl(_ urlString:String) {
    let url = URL(string: urlString)!
    if #available(iOS 10.0, *) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
      UIApplication.shared.openURL(url)
    }
  }
}
