//
//  DBCreation.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/16.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RealmSwift

struct DBCreation {
  
  static func run() {
    createDatabase()
    
    exit(0)
  }
  
  private static func createDatabase() {
    
    print("Creating database")
    
    print("Finish creating database")
  }
  
}
