//
//  DBCreation.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/16.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import RealmSwift

class DBCreation {
  
  // Company Mac
  //let projectFolder = "/Users/tuan/0.Projects/easykiip/"
  // My Mac
  let projectFolder = "/Users/tuan/0.Apps/EasyKIIP/"
  lazy var csvFolder = projectFolder + "Database/CSV/CSVFiles/"
  lazy var bookFilePath = csvFolder + "book.csv"
  lazy var realmFilePath = projectFolder + "Database/vocabBundled.realm"
  
  func run() {
    createDatabase()
    
    exit(0)
  }
  
  private func createDatabase() {
    
    guard let bookFileContent = openCSV(filePath: bookFilePath) else {
      return
    }
    
    let realmFileURL = URL(fileURLWithPath: realmFilePath)
    
    let configuration = Realm.Configuration(fileURL: realmFileURL, deleteRealmIfMigrationNeeded: true)
    let realm = try! Realm(configuration: configuration)
    
    try! realm.write {
      realm.deleteAll()
    }
    
    print("Creating database")
    
    do {
      let bookCSV = try CSVReader(string: bookFileContent, hasHeaderRow: true)
      while let bookFields = bookCSV.next() {
        
        guard bookFields.count >= 3 else {
          continue
        }
        
        let bookID = bookFields[0]
        let bookName = bookFields[1]
        let bookThumb = bookFields[2]
        
        let lessonPath = csvFolder + "\(bookID)/lesson.csv"
        guard let lessonFileContent = openCSV(filePath: lessonPath) else {
          continue
        }
        
        let book = RealmBook(id: Int(bookID)!, name: bookName, thumbName: bookThumb, lessons: [])
        
        do {
          let lessonCSV = try CSVReader(string: lessonFileContent, hasHeaderRow: true)
          while let lessonFields = lessonCSV.next() {
            
            guard lessonFields.count >= 6 else {
              continue
            }
            
            //ID  BookID  Index  Name  vi  en
            let lessonID = lessonFields[0]
            let lessonIndex = lessonFields[2]
            let lessonName = lessonFields[3]
            let lessonNameVi = lessonFields[4]
            let lessonNameEn = lessonFields[5]
            
            let vocabPath = csvFolder + "\(bookID)/\(lessonIndex)v.csv"
            let readingPath = csvFolder + "\(bookID)/\(lessonIndex)r.csv"
            let grammarPath = csvFolder + "\(bookID)/\(lessonIndex)g.csv"
            
            var lessonNameTranslation: [RealmTranslation] = []
            if !lessonNameVi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
              lessonNameTranslation.append(RealmTranslation(languageCode: LanguageCode.vi.rawValue, translation: lessonNameVi))
            }
            
            if !lessonNameEn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
              lessonNameTranslation.append(RealmTranslation(languageCode: LanguageCode.en.rawValue, translation: lessonNameEn))
            }
            
            let lesson = RealmLesson(id: Int(lessonID)!,
                                     name: lessonName,
                                     index: Int(lessonIndex)!,
                                     translations: lessonNameTranslation,
                                     readingParts: [], vocabs: [], grammars: [])
            
            do {
              if let vocabFileContent = openCSV(filePath: vocabPath) {
                let vocabCSV = try CSVReader(string: vocabFileContent, hasHeaderRow: true)
                while let vocabFields = vocabCSV.next() {
                  //ID  LessonID  Word  vi  en
                  let vocabID = vocabFields[0]
                  let word = vocabFields[2]
                  let vi = vocabFields[3]
                  let en = vocabFields[4]
                  
                  guard let id = Int(vocabID) else { continue }

                  var vocabTranslation: [RealmTranslation] = []
                  if !vi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    vocabTranslation.append(RealmTranslation(languageCode: LanguageCode.vi.rawValue, translation: vi))
                  }
                  
                  if !en.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    vocabTranslation.append(RealmTranslation(languageCode: LanguageCode.en.rawValue, translation: en))
                  }
                  
                  let vocab = RealmVocab(id: id, word: word, translations: vocabTranslation)
                  lesson.vocabs.append(vocab)
                }
              }
            }
            catch {
              print(error)
            }
            
            if let readingFileContent = openCSV(filePath: readingPath) {
              do {
                let readingCSV = try CSVReader(string: readingFileContent, hasHeaderRow: true)
                while let readingFields = readingCSV.next() {
                  //Name  Script  name_vi  name_en  script_vi  script_en
                  let scriptName = readingFields[0]
                  let script = readingFields[1]
                  let name_vi = readingFields[2]
                  let name_en = readingFields[3]
                  let script_vi = readingFields[4]
                  let script_en = readingFields[5]

                  var nameTrans: [RealmTranslation] = []
                  var trans: [RealmTranslation] = []
                  
                  if !script_vi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    nameTrans.append(RealmTranslation(languageCode: LanguageCode.vi.rawValue, translation: name_vi))
                    trans.append(RealmTranslation(languageCode: LanguageCode.vi.rawValue, translation: script_vi))
                  }
                  
                  if !script_en.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    nameTrans.append(RealmTranslation(languageCode: LanguageCode.en.rawValue, translation: name_en))
                    trans.append(RealmTranslation(languageCode: LanguageCode.en.rawValue, translation: script_en))
                  }
                  
                  let readingPart = RealmReadingPart(scriptName: scriptName, script: script, scriptNameTranslations: nameTrans, scriptTranslations: trans)
                  
                  lesson.readingParts.append(readingPart)
                }
              }
            }
            
            if let grammarFileContent = openCSV(filePath: grammarPath) {
              do {
                let grammarCSV = try CSVReader(string: grammarFileContent, hasHeaderRow: true)
                while let fields = grammarCSV.next() {
                  //Name  Example  Similar  Explaination_vi  Example_vi  Explaination_en  Example_en
                  guard fields.count >= 7 else { continue }
                  let name = fields[0]
                  let example = fields[1]
                  let similar = fields[2]
                  let explaination_vi = fields[3]
                  let example_vi = fields[4]
                  let explaination_en = fields[5]
                  let example_en = fields[6]

                  var exampleTrans: [RealmTranslation] = []
                  var explainationTrans: [RealmTranslation] = []
                  
                  if !explaination_vi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    explainationTrans.append(RealmTranslation(languageCode: LanguageCode.vi.rawValue, translation: explaination_vi))
                  }
                  
                  if !explaination_en.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    explainationTrans.append(RealmTranslation(languageCode: LanguageCode.en.rawValue, translation: explaination_en))
                  }
                  
                  if !example_vi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    exampleTrans.append(RealmTranslation(languageCode: LanguageCode.vi.rawValue, translation: example_vi))
                  }
                  
                  if !example_en.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    exampleTrans.append(RealmTranslation(languageCode: LanguageCode.en.rawValue, translation: example_en))
                  }
                  
                  let grammar = RealmGrammar(name: name, example: example, similarGrammar: similar, explainationTranslations: explainationTrans, exampleTranslations: exampleTrans)
                  
                  lesson.grammars.append(grammar)
                }
              }
            }
            
            book.lessons.append(lesson)
          }
        }
        catch {
          print(error)
        }
        
        try! realm.write {
          realm.add(book)
        }
      }
    }
    catch {
      print(error)
    }
    
    print("Finish creating database: \(realm.configuration.fileURL)")
  }
  
  private func openCSV(filePath: String)-> String? {
    do {
      let contents = try String(contentsOfFile: filePath, encoding: .utf8)
      return contents
    } catch {
      print("File Read Error for file \(filePath) \(error)")
      return nil
    }
  }
  
}
