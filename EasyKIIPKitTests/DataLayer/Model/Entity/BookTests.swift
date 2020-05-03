//
//  BookTests.swift
//  EasyKIIPKitTests
//
//  Created by Real Life Swift on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
@testable import EasyKIIPKit

class BookTests: XCTestCase {
  
  func testProficiency_NoLesson_Proficiency100() {
    let sut = Book(id: 0, name: "", thumbURL: nil, lessons: [])
    XCTAssertEqual(sut.proficiency, 100)
  }
  
  func testProficiency_OneLesson_NoVocab_Proficiency100() {
    let lession = Lesson(id: 0, name: "", translations: [:], vocabs: [], readingParts: [])
    let sut = Book(id: 0, name: "", thumbURL: nil, lessons: [lession])
    XCTAssertEqual(sut.proficiency, 100)
  }
  
  func testProficiency_OneLesson_OneVocab_NotLearned_Proficiency0() {
    let vocab = Vocab(id: 0, word: "", translations: [:])
    let lession = Lesson(id: 0, name: "", translations: [:], vocabs: [vocab], readingParts: [])
    let sut = Book(id: 0, name: "", thumbURL: nil, lessons: [lession])
    XCTAssertEqual(sut.proficiency, 0)
  }
  
  func testProficiency_OneLesson_OneVocab_Mastered_Proficiency100() {
    let vocab = Vocab(id: 0, word: "", translations: [:])
    vocab.markAsIsMastered()
    let lession = Lesson(id: 0, name: "", translations: [:], vocabs: [vocab], readingParts: [])
    let sut = Book(id: 0, name: "", thumbURL: nil, lessons: [lession])
    XCTAssertEqual(sut.proficiency, 100)
  }
  
  func testProficiency_TwoLesson_One0_One100_Proficiency50() {
    let vocab1 = Vocab(id: 0, word: "", translations: [:])
    vocab1.markAsIsMastered()
    let lession1 = Lesson(id: 0, name: "", translations: [:], vocabs: [vocab1], readingParts: [])
    
    let vocab2 = Vocab(id: 0, word: "", translations: [:])
    let lession2 = Lesson(id: 0, name: "", translations: [:], vocabs: [vocab2], readingParts: [])
    
    let sut = Book(id: 0, name: "", thumbURL: nil, lessons: [lession1, lession2])
    XCTAssertEqual(sut.proficiency, 50)
  }
  
  func testProficiency_ThreeLesson_Two0_One100_Proficiency33() {
    let vocab1 = Vocab(id: 0, word: "", translations: [:])
    vocab1.markAsIsMastered()
    let lession1 = Lesson(id: 0, name: "", translations: [:], vocabs: [vocab1], readingParts: [])
    
    let vocab2 = Vocab(id: 0, word: "", translations: [:])
    let lession2 = Lesson(id: 0, name: "", translations: [:], vocabs: [vocab2], readingParts: [])
    
    let vocab3 = Vocab(id: 0, word: "", translations: [:])
    let lession3 = Lesson(id: 0, name: "", translations: [:], vocabs: [vocab3], readingParts: [])
    
    let sut = Book(id: 0, name: "", thumbURL: nil, lessons: [lession1, lession2, lession3])
    XCTAssertEqual(sut.proficiency, 33)
  }
}
