//
//  ParagraphViewVM.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/15.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ParagraphViewVM {
  
  var oScript: Observable<Script> {
    return rScript.asObservable()
  }
  
  private let rScript: BehaviorRelay<Script>
  
  private let script: Script
  
  init(script: Script) {
    self.script = script
    self.rScript = BehaviorRelay<Script>(value: script)
  }
  
}
