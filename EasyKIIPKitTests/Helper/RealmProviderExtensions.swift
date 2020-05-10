//
//  RealmProviderExtensions.swift
//  EasyKIIPKitTests
//
//  Created by Tuan on 2020/05/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RealmSwift

@testable import EasyKIIPKit

extension RealmProvider {
  func copyForTesting() -> RealmProvider {
    var conf = self.configuration
    conf.inMemoryIdentifier = UUID().uuidString
    conf.readOnly = false
    return RealmProvider(config: conf)
  }
}

extension Realm {
  func addForTesting(objects: [Object]) {
    try! write {
      add(objects)
    }
  }
}
