//
//  Path.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/17.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

enum PathError: Error, LocalizedError {
  case notFound
  case containerNotFound(String)

  var errorDescription: String? {
    switch self {
    case .notFound: return "Resource not found"
    case .containerNotFound(let id): return "Shared container for group \(id) not found"
    }
  }
}

class Path {
  static func inLibrary(_ name: String) throws -> URL {
    return try FileManager.default
      .url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent(name)
  }

  static func inDocuments(_ name: String) throws -> URL {
    return try FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent(name)
  }

  static func inBundle(bundle: Bundle, fileName: String) throws -> URL {
    guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
      throw PathError.notFound
    }
    return url
  }

  static func documents() throws -> URL {
    return try FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
  }
}
