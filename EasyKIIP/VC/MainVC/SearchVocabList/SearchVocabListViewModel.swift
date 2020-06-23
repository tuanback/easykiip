//
//  SearchVocabListViewModel.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/06/23.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import EasyKIIPKit

class SearchVocabListViewModel {
  
  var oListOfVocabsItemViewModels: Observable<[VocabListItemViewModel]> {
    return rVocabs.map { [weak self] (vocabs) in
      guard let strongSelf = self else {
        return []
      }
      
      return strongSelf.createListOfVocabsViewModels(from: vocabs)
    }
  }
  
  private let rVocabs = BehaviorRelay<[Vocab]>(value: [])
  
  init(vocabs: [Vocab]) {
    rVocabs.accept(vocabs)
  }
  
  func setVocabs(_ vocabs: [Vocab]) {
    rVocabs.accept(vocabs)
  }
  
  private func createListOfVocabsViewModels(from vocabs: [Vocab]) -> [VocabListItemViewModel] {
    return ToDetailViewModelConverter.convertVocabsToVocabListItemVMs(vocabs: vocabs)
  }
  
}
