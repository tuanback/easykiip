//
//  FirestoreKey.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/10.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

struct FireStoreUtil {
  
  struct Collection {
    static let users = "users"
    static let books = "books"
    static let lessons = "lessons"
  }
  
  struct Document {
    
    static func getBookDocument(bookID: Int) -> String {
      return "book_\(bookID)"
    }
    
    static func getLessonDocument(lessonID: Int) -> String {
      return "lesson_\(lessonID)"
    }
    
  }
  
  struct User {
    static let userID = "userID"
    static let name = "name"
    static let email = "email"
    static let profileURL = "profileURL"
  }
  
  struct Book {
    static let bookID = "bookID"
    static let lessons = "lessons"
  }
  
  struct Lesson {
    static let key = "lesson_"
    static let lessonID = "lessonID"
    static let vocabs = "vocabs"
    static let proficiency = "proficiency"
    static let lastTimeSynced = "lastTimeSynced"
  }
  
  struct Vocab {
    static let key = "vocab_"
    static let learned = "learned"
    static let taken = "taken"
    static let correct = "correct"
    static let master = "master"
    static let firstDate = "firstDate"
    static let lastDate = "lastDate"
  }
  
  static func bookDocumentPath(userID: String, bookID: Int) -> String {
    let bookDocumentPath = Document.getBookDocument(bookID: bookID)
    let path = Collection.users + "/\(userID)/" + Collection.books + "/\(bookDocumentPath)"
    return path
  }
  
  static func lessonDocumentPath(userID: String, bookID: Int, lessonID: Int) -> String {
    let bookDocumentPath = Document.getBookDocument(bookID: bookID)
    let lessonDocPath = Document.getLessonDocument(lessonID: lessonID)
    let path = Collection.users + "/\(userID)/" + Collection.books + "/\(bookDocumentPath)/" + Collection.lessons + "/\(lessonDocPath)"
    return path
  }
  
}
