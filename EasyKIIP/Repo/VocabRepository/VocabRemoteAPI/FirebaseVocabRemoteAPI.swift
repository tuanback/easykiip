//
//  FirebaseVocabRemoteAPI.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/10.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit

class FirebaseVocabRemoteAPI: VocabRemoteAPI {
  
  func loadLessonData(userID: String, bookID: Int, completion: @escaping ([FirebaseLesson]) -> ()) {
    
  }
  
  func loadVocabData(userID: String, bookID: Int, lessonID: Int, completion: @escaping ([FirebaseVocab]) -> ()) {
    
  }
  
  func saveLessonHistory(userID: String, bookID: Int, lesson: FirebaseLesson) {
    
  }
  
  func saveVocabHistory(userID: String, bookID: Int, lessonID: Int, vocabs: [FirebaseVocab]) {
    
  }
  
}
