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
  }
  
  static func bookDocumentPath(userID: String, bookID: Int) -> String {
    let bookDocumentPath = Document.getBookDocument(bookID: bookID)
    let path = Collection.users + "/\(userID)/" + Collection.books + "/\(bookDocumentPath)"
    return path
  }
  
}
