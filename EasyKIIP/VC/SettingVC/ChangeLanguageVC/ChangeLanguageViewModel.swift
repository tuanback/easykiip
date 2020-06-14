//
//  ChangeLanguageViewModel.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/14.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit
import RxSwift
import RxCocoa
import RxDataSources

struct LanguageSection {
  var items: [LanguageCode]
}

extension LanguageSection: SectionModelType {
  init(original: LanguageSection, items: [LanguageCode]) {
    self = original
    self.items = items
  }
}

class ChangeLanguageViewModel {
  
  var oSections: Observable<[LanguageSection]> {
    return rSections.asObservable()
  }
  
  private var rSections = BehaviorRelay<[LanguageSection]>(value: [])
  
  init() {
    let section = LanguageSection(items: LanguageCode.allCases)
    rSections.accept([section])
  }
  
  func handleLanguageSelected(_ code: LanguageCode) {
    AppSetting.languageCode = code
  }
  
}
