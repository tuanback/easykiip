//
//  SettingSection.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

class SettingSection {
  
  private(set) var settingSectionItem: SettingSectionItem
  private(set) var settingItems: [SettingItem] = []
  
  init(settingSectionItem: SettingSectionItem, settingItems: [SettingItem]) {
    self.settingSectionItem = settingSectionItem
    self.settingItems = settingItems
  }
  
}
