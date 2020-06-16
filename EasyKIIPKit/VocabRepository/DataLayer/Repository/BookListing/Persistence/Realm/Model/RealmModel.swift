//
//  RealmModel.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/05/09.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RealmSwift

private func convertListTranslationToDict(_ list: List<RealmTranslation>) -> [LanguageCode: String] {
  
  var dict: [LanguageCode: String] = [:]
  
  for i in list {
    let (languageCode, translation) = i.getLanguageCodeAndTranslation()
    dict[languageCode] = translation
  }
  
  return dict
}

class RealmBook: Object {
  @objc dynamic var id: Int = 0
  @objc dynamic var name: String = ""
  @objc dynamic var thumbName: String?
  
  let lessons = List<RealmLesson>()
  
  convenience init(id: Int, name: String, thumbName: String?, lessons: [RealmLesson]) {
    self.init()
    self.id = id
    self.name = name
    self.thumbName = thumbName
    self.lessons.append(objectsIn: lessons)
  }
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  func toBook() -> Book {
    var thumbURL: URL? = nil
    if let thumbName = self.thumbName,
      let url = Bundle(for: type(of: self)).url(forResource: thumbName, withExtension: "") {
      thumbURL = url
    }
    let lessons: [Lesson] = self.lessons.map { $0.toLesson() }
    return Book(id: id, name: name, thumbURL: thumbURL, lessons: lessons)
  }
}

class RealmLesson: Object {
  @objc dynamic var id: Int = 0
  @objc dynamic var name: String = ""
  @objc dynamic var index: Int = 1
  
  let translations = List<RealmTranslation>()
  let readingParts = List<RealmReadingPart>()
  let vocabs = List<RealmVocab>()
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  convenience init(id: Int, name: String, index: Int,
                   translations: [RealmTranslation],
                   readingParts: [RealmReadingPart],
                   vocabs: [RealmVocab]) {
    self.init()
    self.id = id
    self.name = name
    self.index = index
    self.translations.append(objectsIn: translations)
    self.readingParts.append(objectsIn: readingParts)
    self.vocabs.append(objectsIn: vocabs)
  }
  
  func toLesson() -> Lesson {
    let trans = convertListTranslationToDict(translations)
    let vocabs: [Vocab] = self.vocabs.map { $0.toVocab() }
    let readingPart: [ReadingPart] = self.readingParts.map { $0.toReadingPart() }
    return Lesson(id: id, name: name, index: index, translations: trans, vocabs: vocabs, readingParts: readingPart)
  }
}

class RealmTranslation: Object {
  @objc dynamic var languageCode: String = ""
  @objc dynamic var translation: String = ""
  
  convenience init(languageCode: String, translation: String) {
    self.init()
    self.languageCode = languageCode
    self.translation = translation
  }
  
  func getLanguageCodeAndTranslation() -> (LanguageCode, String) {
    let code = LanguageCode(rawValue: languageCode) ?? .en
    return (code, translation)
  }
}

class RealmReadingPart: Object {
  @objc dynamic var scriptName: String = ""
  @objc dynamic var script: String = ""
  
  let scriptNameTranslations = List<RealmTranslation>()
  let scriptTranslations = List<RealmTranslation>()
  
  convenience init(scriptName: String,
                   script: String,
                   scriptNameTranslations: [RealmTranslation],
                   scriptTranslations: [RealmTranslation]) {
    self.init()
    self.scriptName = scriptName
    self.script = script
    self.scriptNameTranslations.append(objectsIn: scriptNameTranslations)
    self.scriptTranslations.append(objectsIn: scriptTranslations)
  }
  
  func toReadingPart() -> ReadingPart {
    let nameTrans = convertListTranslationToDict(scriptNameTranslations)
    let scriptTrans = convertListTranslationToDict(scriptTranslations)
    return ReadingPart(scriptName: scriptName, script: script, scriptNameTranslation: nameTrans, scriptTranslation: scriptTrans)
  }
}

class RealmVocab: Object {
  @objc dynamic var id: Int = 0
  @objc dynamic var word: String = ""
  
  let translations = List<RealmTranslation>()
  
  override class func primaryKey() -> String? {
    return "id"
  }
  
  convenience init(id: Int, word: String, translations: [RealmTranslation]) {
    self.init()
    self.id = id
    self.word = word
    self.translations.append(objectsIn: translations)
  }
  
  func toVocab() -> Vocab {
    let trans = convertListTranslationToDict(translations)
    return Vocab(id: id, word: word, translations: trans)
  }
}

class RealmLessonHistory: Object {
  @objc dynamic var lessonID: Int = 0
  @objc dynamic var isSynced: Bool = true
  @objc dynamic var proficiency: Int = 0
  @objc dynamic var lastTimeLearned: Date?
  @objc dynamic var numberOfVocabs: Int = 0
  
  /// Last time synced is stored as Date since 1970
  let lastTimeSynced = RealmOptional<Double>()
  
  let vocabsHistory = List<RealmVocabPracticeHistory>()
  
  override class func primaryKey() -> String? {
    return "lessonID"
  }
  
  convenience init(lessonID: Int, numberOfVocabs: Int, isSynced: Bool, lastTimeSynced: Double?, proficiency: Int, lastTimeLearned: Date?) {
    self.init()
    self.lessonID = lessonID
    self.numberOfVocabs = numberOfVocabs
    self.isSynced = isSynced
    self.lastTimeSynced.value = lastTimeSynced
    self.proficiency = proficiency
    self.lastTimeLearned = lastTimeLearned
  }
  
  func calculateProficiency() -> UInt8 {
    guard vocabsHistory.count > 0 else { return 0 }
    let total = vocabsHistory.reduce(0) { (result, vocabHistory) -> UInt in
      result + UInt(vocabHistory.proficiency)
    }
    let count = UInt(numberOfVocabs)
    return UInt8(total / count)
  }
}

class RealmVocabPracticeHistory: Object {
  @objc dynamic var vocabID: Int = 0
  @objc dynamic var testTaken: Int = 0
  @objc dynamic var correctAnswer: Int = 0
  @objc dynamic var wrongAnswer: Int = 0
  @objc dynamic var isLearned: Bool = false
  @objc dynamic var isMastered: Bool = false
  @objc dynamic var firstLearnDate: Date?
  @objc dynamic var lastTimeTest: Date?
  /// Store the status that the vocab is synced with the server or nor
  @objc dynamic var isSynced = false
  
  var proficiency: UInt8 {
    return ProficiencyCalculator.calculate(isMastered: isMastered,
                                           isLearned: isLearned,
                                           lastTimeTest: lastTimeTest,
                                           correctAnswer: correctAnswer)
  }
  
  override class func primaryKey() -> String? {
    return "vocabID"
  }
  
  convenience init(vocabID: Int,
                   testTaken: Int,
                   correctAnswer: Int,
                   wrongAnswer: Int,
                   isLearned: Bool,
                   isMastered: Bool,
                   firstLearnDate: Date?,
                   lastTimeTest: Date?) {
    self.init()
    self.vocabID = vocabID
    self.testTaken = testTaken
    self.correctAnswer = correctAnswer
    self.wrongAnswer = wrongAnswer
    self.isMastered = isMastered
    if isMastered {
      self.isLearned = true
    }
    else {
      self.isLearned = isLearned
    }
    
    self.firstLearnDate = firstLearnDate
    self.lastTimeTest = lastTimeTest
  }
}
