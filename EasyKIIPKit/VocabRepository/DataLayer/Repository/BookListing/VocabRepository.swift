//
//  VocabRepository.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/20.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RxSwift

public protocol SearchEngine {
  func searchVocab(keyword: String) -> [Vocab]
}

public protocol NeedMorePracticeVocabGetter {
  func getListOfLowProficiencyVocab(inBook id: Int, upto numberOfVocabs: Int) -> [Vocab]
  func getListOfLowProficiencyVocab(inLesson id: Int, upto numberOfVocabs: Int) -> [Vocab]
}

public protocol NeedReviewVocabsGetter {
  /// Get list of vocabs in all the books if the users didn't review the learned vocab after 1 days 1 week or one months
  func getNeedReviewVocabs(upto numberOfVocabs: Int) -> [Vocab]
  /// Get list of vocabs in a specific book if the users didn't review the learned vocab after 1 days 1 week or one months
  func getNeedReviewVocabs(inBook id: Int, upto numberOfVocabs: Int) -> [Vocab]
}

public protocol VocabRepository: SearchEngine, NeedMorePracticeVocabGetter, NeedReviewVocabsGetter {
  func getListOfBook() -> [Book]
  func getListOfLesson(inBook id: Int) -> Observable<[Lesson]>
  func getLesson(inBook id: Int, lessonID: Int) -> Observable<Lesson>
  func getListOfVocabs(inBook bookID: Int, inLesson lessonID: Int) -> Observable<[Vocab]>
  func markVocabAsMastered(vocabID id: Int)
  func recordVocabPracticed(vocabID: Int, isCorrectAnswer: Bool)
  func saveLessonPracticeHistory(inBook id: Int, lessonID: Int)
  
  func getRandomVocabs(differentFromVocabIDs: [Int], upto numberOfVocabs: Int) -> [Vocab]
}
