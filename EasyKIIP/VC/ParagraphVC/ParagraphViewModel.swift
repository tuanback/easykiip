//
//  ParagraphViewModel.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/15.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit
import RxSwift
import RxCocoa

struct Script: Equatable {
  let name: String
  let translation: String
}

class ParagraphViewModel {
  
  var oScripts: Observable<[Script]> {
    return rScripts.asObservable()
  }
  
  private let rScripts: BehaviorRelay<[Script]>
  
  private let readingPart: ReadingPart
  
  init(readingPart: ReadingPart) {
    self.readingPart = readingPart
    
    var scripts = [Script]()
    let koreanScript = Script(name: readingPart.scriptName,
                              translation: readingPart.script)
    scripts.append(koreanScript)
    
    let appLanguage = AppSetting.languageCode
    if let scriptName = readingPart.scriptNameTranslation[appLanguage],
      let script = readingPart.scriptTranslation[appLanguage] {
      let translation = Script(name: scriptName, translation: script)
      scripts.append(translation)
    }
    
    rScripts = BehaviorRelay<[Script]>(value: scripts)
  }
  
}
