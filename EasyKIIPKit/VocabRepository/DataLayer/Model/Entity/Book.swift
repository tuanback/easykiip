//
//  Book.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class Book {
  public private(set) var id: UInt
  public private(set) var name: String
  public private(set) var thumbURL: URL?
  private(set) var lessons: [Lesson]
  
  public var proficiency: UInt8 {
    guard lessons.count > 0 else { return 100 }
    let total = lessons.reduce(0) { (result, Lesson) -> UInt in
      result + UInt(Lesson.proficiency)
    }
    let count = UInt(lessons.count)
    return UInt8(total / count)
  }
  
  public init(id: UInt, name: String, thumbURL: URL?, lessons: [Lesson]) {
    self.id = id
    self.name = name
    self.thumbURL = thumbURL
    self.lessons = lessons
  }
}
