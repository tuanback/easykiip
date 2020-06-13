//
//  Spy.swift
//  EasyKIIPTests
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class Spy<T> {
  private(set) var values: [T] = []
  
  private let disposeBag = DisposeBag()
  
  init(observable: Observable<T>) {
    
    observable
      .subscribe(onNext: { [weak self] value in
        self?.values.append(value)
      })
      .disposed(by: disposeBag)
  }
}
