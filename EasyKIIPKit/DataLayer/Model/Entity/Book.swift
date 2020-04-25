//
//  Book.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public struct Book {
  public private(set) var id: UInt
  public private(set) var name: String
  public private(set) var thumbName: String?
  public private(set) var lessions: [Lesson]
  
  public var proficiency: UInt8 {
    guard lessions.count > 0 else { return 100 }
    let total = lessions.reduce(0) { (result, Lesson) -> UInt in
      result + UInt(Lesson.proficiency)
    }
    let count = UInt(lessions.count)
    return UInt8(total / count)
  }
}
