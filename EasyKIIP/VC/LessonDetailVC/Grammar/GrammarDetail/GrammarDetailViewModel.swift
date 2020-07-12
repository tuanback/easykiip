//
//  GrammarDetailViewModel.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/07/12.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit
import RxSwift
import RxCocoa

class GrammarDetailViewModel {
  
  var oName: Driver<String> {
    return rName.asDriver()
  }
  
  var oSimilarGrammar: Driver<String?> {
    return rSimilarGrammar.asDriver()
  }
  
  var oSimilarTitle: Driver<String?> {
    return rSimilarGrammar.map { (text) in
      if text == nil || text == "" {
        return nil
      }
      else {
        return Strings.sameMeaningGrammar
      }
    }
    .asDriver(onErrorJustReturn: nil)
  }
  
  var oExplaination: Driver<String?> {
    return rExplaination.asDriver()
  }
  
  var oExample: Driver<String> {
    return rExample.asDriver()
  }
  
  private var rName = BehaviorRelay<String>(value: "")
  private var rSimilarGrammar = BehaviorRelay<String?>(value: nil)
  private var rExplaination = BehaviorRelay<String?>(value: nil)
  private var rExample = BehaviorRelay<String>(value: "")
  
  private let grammar: Grammar
  
  init(grammar: Grammar) {
    self.grammar = grammar
    
    rName.accept(grammar.name)
    rSimilarGrammar.accept(grammar.similarGrammar)
    let explaination = grammar.explainationTranslations[AppSetting.languageCode]
    rExplaination.accept(explaination)
    
    let exampleTranslation = grammar.exampleTranslations[AppSetting.languageCode] ?? ""
    let exampleText = grammar.example + "\n" + exampleTranslation
    rExample.accept(exampleText)
  }
  
}
