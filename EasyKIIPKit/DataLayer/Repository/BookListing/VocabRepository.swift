//
//  VocabRepository.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public protocol SearchEngine {
  func searchVocab(keywork: String) -> [Vocab]
}

public protocol NeedMorePracticeVocabGetter {
  func getListOfLowProficiencyVocab(in book: Book, upto numberOfVocabs: Int) -> [Vocab]
  func getListOfLowProficiencyVocab(in lession: Lesson, upto numberOfVocabs: Int) -> [Vocab]
}

public protocol NeedReviewVocabsGetter {
  /// Get list of vocabs in all the books if the users didn't review the learned vocab after 1 days 1 week or one months
  func getNeedReviewVocabs(upto numberOfVocabs: Int) -> [Vocab]
  /// Get list of vocabs in a specific book if the users didn't review the learned vocab after 1 days 1 week or one months
  func getNeedReviewVocabs(in book: Book, upto numberOfVocabs: Int) -> [Vocab]
}

public protocol VocabRepository: SearchEngine, NeedMorePracticeVocabGetter, NeedReviewVocabsGetter {
  func getListOfBook() -> [Book]
  func getListOfLesson(in book: Book) -> [Lesson]
  func getListOfVocabs(in lesson: Lesson) -> [Vocab]
  func markVocabAsMastered(_ vocab: Vocab)
  func recordVocabPracticed(vocab: Vocab, isCorrectAnswer: Bool)
}
