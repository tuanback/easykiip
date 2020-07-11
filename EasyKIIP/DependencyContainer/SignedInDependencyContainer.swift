//
//  SignedInDependencyContainer.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import EasyKIIPKit
import Firebase
import Foundation
import UIKit
import UserSession
import Purchases

public class SignedInDependencyContainer {
  
  let userSessionRepository: UserSessionRepository
  let vocabRepository: VocabRepository
  
  init(appDenpendencyContainer: AppDependencyContainer) {
    func makeRemoteAPI() -> VocabRemoteAPI {
      return FirebaseVocabRemoteAPI()
    }
    
    func makeVocabDataStore() -> VocabDataStore {
      return RealmDataStore()
    }
    
    func makeVocabRepository(userSessionRepo: UserSessionRepository) -> VocabRepository {
      let remoteAPI = makeRemoteAPI()
      let dataStore = makeVocabDataStore()
      let vocabRepository = KIIPVocabRepository(userSessionRepo: userSessionRepo,
                                                remoteAPI: remoteAPI,
                                                dataStore: dataStore)
      return vocabRepository
      
    }
    
    self.userSessionRepository = appDenpendencyContainer.userSessionRepository
    self.vocabRepository = makeVocabRepository(userSessionRepo: userSessionRepository)
  }
  
  deinit {
    print("Deinit")
  }
  
  func makeMainNavVC() -> MainNavVC {
    func makeMainNavNavigator() -> MainNavConNavigator {
      return MainNavConNavigator(factory: self)
    }
    
    let viewModel = MainNavViewModel()
    let mainNavVC = MainNavVC(viewModel: viewModel, navigator: makeMainNavNavigator())
    return mainNavVC
  }
  
  func makeMainVC() -> MainVC {
    func makeMainNavigator() -> MainNavigator {
      return MainNavigator(factory: self)
    }
    
    let viewModel = makeMainViewModel()
    let mainVC = MainVC(viewModel: viewModel,
                        navigator: makeMainNavigator())
    return mainVC
  }
  
  func makeMainViewModel() -> MainViewModel {
    let mainVM = MainViewModel(userSessionRepository: userSessionRepository, vocabRepository: vocabRepository)
    return mainVM
  }
  
  func makeBookDetailVC(bookID: Int, bookName: String) -> BookDetailVC {
    
    func makeViewModel(bookID: Int, bookName: String) -> BookDetailViewModel {
      return BookDetailViewModel(bookID: bookID, bookName: bookName, vocabRepository: vocabRepository, isPaidUser: userSessionRepository.isUserSubscribed())
    }
    
    let navigator = BookDetailNavigator(factory: self)
    let viewModel = makeViewModel(bookID: bookID, bookName: bookName)
    return BookDetailVC(viewModel: viewModel, navigator: navigator)
  }
  
  func makeSettingVC() -> UIViewController {
    let viewModel = SettingVM(userSessionRepository: userSessionRepository)
    let navigator = SettingNavigator(factory: self)
    return UINavigationController(rootViewController: SettingVC(viewModel: viewModel,
                                                                navigator: navigator))
  }
  
  func makeLanguageSettingVC() -> UIViewController {
    let viewModel = ChangeLanguageViewModel()
    return ChangeLanguageVC(viewModel: viewModel)
  }
  
  func makeLoginVC(signedInResponder: SignedInResponder?) -> LoginVC {
    let viewModel = makeLoginViewModel(signedInResponder: signedInResponder)
    return LoginVC(viewModel: viewModel)
  }
  
  private func makeLoginViewModel(signedInResponder: SignedInResponder?) -> LoginViewModel {
    let viewModel = LoginViewModel(userSessionRepository: userSessionRepository,
                                   signedInResponder: signedInResponder)
    return viewModel
  }
  
  func makeLessonDetailVC(bookID: Int, lessonID: Int) -> LessonDetailVC {
    let viewModel = LessonDetailViewModel(bookID: bookID,
                                          lessonID: lessonID,
                                          vocabRepository: vocabRepository,
                                          isPaidUser: userSessionRepository.isUserSubscribed())
    let navigator = LessonDetailNavigator(factory: self)
    return LessonDetailVC(viewModel: viewModel, navigator: navigator)
  }
  
  func makeParagraphVC(readingPart: ReadingPart) -> ParagraphVC {
    let viewModel = ParagraphViewModel(readingPart: readingPart)
    return ParagraphVC(viewModel: viewModel)
  }
  
  func makePayWallVC() -> UIViewController {
    return SwiftPaywall()
  }
  
  func makeQuizNewWordVC(bookID: Int, lessonID: Int, vocabs: [Vocab]) -> QuizVC {
   
    let randomVocabs: [Vocab] = vocabRepository.getRandomVocabs(differentFromVocabIDs: vocabs.map { $0.id }, upto: vocabs.count)
    
    let questionMaker = NewWordQuestionMaker(createQuestionVocabs: vocabs, randomVocabs: randomVocabs, languageCode: AppSetting.languageCode)
    
    let vc = makeQuizVC(bookID: bookID, lessonID: lessonID, vocabs: vocabs, questionMaker: questionMaker, numberOfHeart: nil)
    return vc
  }
  
  func makeQuizPracticeVC(bookID: Int, lessonID: Int, vocabs: [Vocab]) -> QuizVC {
    
    let randomVocabs: [Vocab] = vocabRepository.getRandomVocabs(differentFromVocabIDs: vocabs.map { $0.id }, upto: vocabs.count)
    
    let questionMaker = PracticeQuestionMaker(createQuestionVocabs: vocabs, randomVocabs: randomVocabs, languageCode: AppSetting.languageCode)
    
    let numberOfHear: Int? = userSessionRepository.isUserSubscribed() ? nil : 3
    
    let vc = makeQuizVC(bookID: bookID, lessonID: lessonID, vocabs: vocabs, questionMaker: questionMaker, numberOfHeart: numberOfHear)
    return vc
  }
  
  private func makeQuizVC(bookID: Int, lessonID: Int, vocabs: [Vocab], questionMaker: QuestionMaker, numberOfHeart: Int?) -> QuizVC {
    let quizEngine = KIIPQuizEngine(bookID: bookID, lessonID: lessonID, vocabs: vocabs, numberOfHeart: numberOfHeart, questionMaker: questionMaker, vocabRepository: vocabRepository)
    let viewModel = QuizViewModel(quizEngine: quizEngine,
                                  isPaidUser: userSessionRepository.isUserSubscribed())
    
    let navigator = QuizNavigator(factory: self)
    return QuizVC(viewModel: viewModel, navigator: navigator)
  }
  
  func makeEndQuizVC(ad: GADUnifiedNativeAd?) -> QuizEndVC {
    let viewModel = QuizEndViewModel(ad: ad,
                                     isPaidUser: userSessionRepository.isUserSubscribed())
    return QuizEndVC(viewModel: viewModel)
  }
  
  func makeVideoAdsVC() -> UIViewController {
    return UIViewController()
  }
  
}

extension SignedInDependencyContainer: MainVCFactory { }
extension SignedInDependencyContainer: BookDetailFactory { }
extension SignedInDependencyContainer: SettingVCFactory { }
extension SignedInDependencyContainer: LessonDetailVCFactory { }
extension SignedInDependencyContainer: QuizNewWordVCFactory { }
extension SignedInDependencyContainer: QuizPracticeVCFactory { }

extension SignedInDependencyContainer: EndQuizAdVCFactory { }
extension SignedInDependencyContainer: VideoAdsVCFactory { }
extension SignedInDependencyContainer: LanguageSettingVCFactory { }
extension SignedInDependencyContainer: LoginVCFactory { }

extension SignedInDependencyContainer: ParagraphVCFactory { }
extension SignedInDependencyContainer: PayWallVCFactory { }
