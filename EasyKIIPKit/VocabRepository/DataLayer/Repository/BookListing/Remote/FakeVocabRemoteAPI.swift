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
  
  public func loadLessonData(userID: String, bookdID: Int, completion: ([FirebaseLesson]) -> ()) {
    
  }
  
  public func loadVocabData(userID: String, lessonID: Int, completion: ([FirebaseVocab]) -> ()) {
    
  }
}
