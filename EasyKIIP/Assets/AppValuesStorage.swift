//
//  AppValuesStorage.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

struct AppValuesStorage {
  
  /// Did Language Set
  static var didSetLanguage: Bool {
    get {
      return UserDefaults.standard.bool(forKey: "AppValuesStorage_didSetLanguage")
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: "AppValuesStorage_didSetLanguage")
    }
  }
  
  static var isNotFirstTimeLaunched: Bool {
    get {
      return UserDefaults.standard.bool(forKey: "AppValuesStorage_isNotFirstTimeLaunched")
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: "AppValuesStorage_isNotFirstTimeLaunched")
    }
  }
  
}
