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
  private var lessonDict: [Int: FirestoreDocument] = [:]
  
  init() { }
  
  func loadLessonData(userID: String, bookID: Int, completion: @escaping ([FirebaseLesson]) -> ()) {
    
    // Check if the firestore document is already existed
    if let fireStoreDocument = bookDict[bookID],
      let snapShot = fireStoreDocument.snapShot {
      // TODO: Parse document to get firebase lesson
      let lessons = parseBookData(snapShot: snapShot)
      completion(lessons)
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
        let lessons = strongSelf.parseBookData(snapShot: document)
        completion(lessons)
      }
      else {
        print("Document doesn't exist. Creating new document")
        docRef.setData([FireStoreUtil.Book.bookID: bookID,
                        FireStoreUtil.Book.lessons: [:]]) { error in
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
  
  private func parseBookData(snapShot: DocumentSnapshot) -> [FirebaseLesson] {
    guard let data = snapShot.data() else {
      return []
    }
    
    var results: [FirebaseLesson] = []
    
    if let lessonDict = data[FireStoreUtil.Book.lessons] as? [String: Any] {
      for (key, value) in lessonDict {
        guard let valueDict = value as? [String: Any] else { continue }
        guard let id = Int(key.dropFirst(FireStoreUtil.Lesson.key.count)),
          let proficiency = valueDict[FireStoreUtil.Lesson.proficiency] as? UInt8,
          let lastTimeSynced = valueDict[FireStoreUtil.Lesson.lastTimeSynced] as? Double else {
            continue
        }
        
        let lesson = FirebaseLesson(id: id,
                                    proficiency: proficiency,
                                    lastTimeSynced: lastTimeSynced)
        results.append(lesson)
      }
    }
    
    return results
  }
  
  func loadVocabData(userID: String, bookID: Int, lessonID: Int, completion: @escaping ([FirebaseVocab]) -> ()) {
    
    // Check if the firestore document is already existed
    if let fireStoreDocument = lessonDict[bookID],
      let snapShot = fireStoreDocument.snapShot {
      // TODO: Parse document to get firebase vocabs
      let vocabs = parseLessonData(snapShot: snapShot)
      completion(vocabs)
      return
    }
    
    let lessonDocPath = FireStoreUtil.lessonDocumentPath(userID: userID, bookID: bookID, lessonID: lessonID)
    
    let docRef = db.document(lessonDocPath)
    docRef.getDocument { [weak self] (document, error) in
      guard let strongSelf = self else { return }
      
      strongSelf.lessonDict[bookID] = FirestoreDocument(reference: docRef, snapShot: document)
      strongSelf.listenToLessonSnapShotChanged(lessonID: lessonID, docRef: docRef)
      
      if let document = document, document.exists {
        // TODO: Parse data then return
        let vocabs = strongSelf.parseLessonData(snapShot: document)
        completion(vocabs)
      }
      else {
        print("Document doesn't exist. Creating new document")
        docRef.setData([FireStoreUtil.Lesson.lessonID: bookID,
                        FireStoreUtil.Lesson.vocabs: [:]]) { error in
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
  
  private func listenToLessonSnapShotChanged(lessonID: Int,
                                             docRef: DocumentReference) {
    
    docRef.addSnapshotListener { [weak self] (document, error) in
      guard let strongSelf = self else { return }
      if let fireStoreDocument = strongSelf.lessonDict[lessonID] {
        print("Lesson \(lessonID) document snapshot changed")
        fireStoreDocument.snapShot = document
      }
    }
  }
  
  private func parseLessonData(snapShot: DocumentSnapshot) -> [FirebaseVocab] {
    guard let data = snapShot.data() else {
      return []
    }
    
    var results: [FirebaseVocab] = []
    
    if let vocabsDict = data[FireStoreUtil.Lesson.vocabs] as? [String: Any] {
      for (key, value) in vocabsDict {
        guard let valueDict = value as? [String: Any] else { continue }
        guard let id = Int(key.dropFirst(FireStoreUtil.Vocab.key.count)),
          let isLearned = valueDict[FireStoreUtil.Vocab.learned] as? Bool,
          let taken = valueDict[FireStoreUtil.Vocab.taken] as? Int,
          let correct = valueDict[FireStoreUtil.Vocab.correct] as? Int,
          let isMastered = valueDict[FireStoreUtil.Vocab.master] as? Bool
          else {
            continue
        }
        
        let firstDate = valueDict[FireStoreUtil.Vocab.firstDate] as? Double
        let lastDate = valueDict[FireStoreUtil.Vocab.lastDate] as? Double
        
        let vocab = FirebaseVocab(id: id, isLearned: isLearned, isMastered: isMastered, testTaken: taken, correctAnswer: correct, firstTimeLearned: firstDate, lastTimeLearned: lastDate)
        results.append(vocab)
      }
    }
    
    return results
  }
  
  func saveLessonHistory(userID: String, bookID: Int, lesson: FirebaseLesson) {
    
    let bookDocumentPath = FireStoreUtil.bookDocumentPath(userID: userID, bookID: bookID)
    
    let docRef = db.document(bookDocumentPath)
    
    let key = "\(FireStoreUtil.Book.lessons).\(FireStoreUtil.Lesson.key)\(lesson.id)"
    let value: [String: Any] = [FireStoreUtil.Lesson.proficiency: lesson.proficiency,
                                FireStoreUtil.Lesson.lastTimeSynced: lesson.lastTimeSynced]
    let lessonDict = [key: value]
    
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
    let lessonDocumentPath = FireStoreUtil.lessonDocumentPath(userID: userID, bookID: bookID, lessonID: lessonID)
    
    let docRef = db.document(lessonDocumentPath)
    
    var vocabsDict: [String: Any] = [:]
    
    for vocab in vocabs {
      let key = "\(FireStoreUtil.Lesson.vocabs).\(FireStoreUtil.Vocab.key)\(vocab.id)"
      var value: [String: Any] = [:]
      value[FireStoreUtil.Vocab.learned] = vocab.isLearned
      value[FireStoreUtil.Vocab.taken] = vocab.testTaken
      value[FireStoreUtil.Vocab.correct] = vocab.correctAnswer
      value[FireStoreUtil.Vocab.master] = vocab.isMastered
      value[FireStoreUtil.Vocab.firstDate] = vocab.firstTimeLearned
      value[FireStoreUtil.Vocab.lastDate] = vocab.lastTimeLearned
      vocabsDict[key] = value
    }
    
    docRef.updateData(vocabsDict) { error in
      if let error = error {
        print("Save vocabs history failed: \(error)")
      }
      else {
        print("Save vocabs history successfully")
      }
    }
    
  }
  
}
