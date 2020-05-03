//
//  FakeVocabRemoteAPI.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class FakeVocabRemoteAPI: VocabRemoteAPI {

  public init() { }
  
  public func loadBookData(userID: String, bookdID: UInt, completion: ([FirebaseBook]) -> ()) {
    
  }
  
  public func loadVocabData(userID: String, lessonID: UInt, completion: ([FirebaseVocab]) -> ()) {
    
  }
}
