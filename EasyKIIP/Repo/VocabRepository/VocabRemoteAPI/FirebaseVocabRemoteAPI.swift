//
//  FirebaseVocabRemoteAPI.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/10.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EasyKIIPKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseVocabRemoteAPI: VocabRemoteAPI {
  
  class FirestoreDocument {
    var reference: DocumentReference
    var snapShot: DocumentSnapshot?
    
    init(reference: DocumentReference,
         snapShot: DocumentSnapshot?) {
      self.reference = reference
      self.snapShot = snapShot
    }
  }
  
  private lazy var db = Firestore.firestore()
  
  private var bookDict: [Int: FirestoreDocument] = [:]
  
  init() { }
  
  func loadLessonData(userID: String, bookID: Int, completion: @escaping ([FirebaseLesson]) -> ()) {
    
    // Check if the firestore document is already existed
    if let fireStoreDocument = bookDict[bookID] {
      // TODO: Parse document to get firebase lesson
      
      return
    }
    
    let bookDocumentPath = FireStoreUtil.bookDocumentPath(userID: userID, bookID: bookID)
    
    let docRef = db.document(bookDocumentPath)
    docRef.getDocument { [weak self] (document, error) in
      guard let strongSelf = self else { return }
      
      strongSelf.bookDict[bookID] = FirestoreDocument(reference: docRef, snapShot: document)
      strongSelf.listenToBookSnapShotChanged(bookID: bookID, docRef: docRef)
      
      if let document = document, document.exists {
        // TODO: Parse data then return
      }
      else {
        print("Document doesn't exist")
        docRef.setData([FireStoreUtil.Book.bookID: bookID]) { error in
          if let err = error {
            print("Can't create book document \(err.localizedDescription)")
          }
          else {
            print("Book document created")
          }
        }
        completion([])
      }
    }
        
  }
  
  private func listenToBookSnapShotChanged(bookID: Int, docRef: DocumentReference) {
    
    docRef.addSnapshotListener { [weak self] (document, error) in
      guard let strongSelf = self else { return }
      if let fireStoreDocument = strongSelf.bookDict[bookID] {
        print("Book \(bookID) document snapshot changed")
        fireStoreDocument.snapShot = document
      }
    }
    
  }
  
  func loadVocabData(userID: String, bookID: Int, lessonID: Int, completion: @escaping ([FirebaseVocab]) -> ()) {
    
  }
  
  func saveLessonHistory(userID: String, bookID: Int, lesson: FirebaseLesson) {
    
    let bookDocumentPath = FireStoreUtil.bookDocumentPath(userID: userID, bookID: bookID)
    
    let docRef = db.document(bookDocumentPath)
    
    let lessonDict = ["lessons": ["lesson_\(lesson.id)": lesson.id,
                                  "proficiency": lesson.proficiency,
                                  "lastTimeSynced": lesson.lastTimeSynced]]
    
    docRef.updateData(lessonDict) { (error) in
      if let error = error {
        print("Save lesson history failed: \(error)")
      }
      else {
        print("Save lesson history successfully")
      }
    }
    
  }
  
  func saveVocabHistory(userID: String, bookID: Int, lessonID: Int, vocabs: [FirebaseVocab]) {
    
  }
  
}
