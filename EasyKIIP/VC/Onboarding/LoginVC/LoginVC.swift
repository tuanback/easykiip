//
//  LoginVC.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import Firebase
import GoogleSignIn
import SVProgressHUD

private var isMFAEnabled = false

public class LoginVC: NiblessViewController {
  
  private let viewModel: LoginViewModel
  private let disposeBag = DisposeBag()
  
  public init(viewModel: LoginViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  public override func loadView() {
    view = LoginRootView(viewModel: viewModel)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupGoogleSignIn()
    observeViewModel()
  }
  
  private func setupGoogleSignIn() {
    GIDSignIn.sharedInstance()?.presentingViewController = self
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance()?.restorePreviousSignIn()
  }
  
  private func observeViewModel() {
    viewModel.textInput
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] message in
        self?.showTextInputPrompt(withMessage: message, completionBlock: { (isOK, text) in
          guard isOK, let text = text else { return }
          self?.viewModel.handleUserTextInputResult(isOK: isOK, text: text)
        })
      })
      .disposed(by: disposeBag)
    
    viewModel.errorMessage
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: showMessagePrompt(_:))
      .disposed(by: disposeBag)
    
    viewModel.oDismiss
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel.oIsLoading
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { isLoading in
        if isLoading {
          SVProgressHUD.show()
        }
        else {
          SVProgressHUD.dismiss()
        }
      })
      .disposed(by: disposeBag)
  }
}

extension LoginVC: GIDSignInDelegate {
  public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    if let error = error {
      print(error)
      return
    }
    
    guard let authentication = user.authentication else { return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                   accessToken: authentication.accessToken)
    viewModel.login(with: credential, provider: .google)
  }
  
  /*! @fn showTextInputPromptWithMessage
   @brief Shows a prompt with a text field and 'OK'/'Cancel' buttons.
   @param message The message to display.
   @param completion A block to call when the user taps 'OK' or 'Cancel'.
   */
  func showTextInputPrompt(withMessage message: String,
                           completionBlock: @escaping ((Bool, String?) -> Void)) {
    let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: Strings.cancel, style: .cancel) { _ in
      completionBlock(false, nil)
    }
    weak var weakPrompt = prompt
    let okAction = UIAlertAction(title: Strings.ok, style: .default) { _ in
      guard let text = weakPrompt?.textFields?.first?.text else { return }
      completionBlock(true, text)
    }
    prompt.addTextField(configurationHandler: nil)
    prompt.addAction(cancelAction)
    prompt.addAction(okAction)
    present(prompt, animated: true, completion: nil)
  }
  
  func showMessagePrompt(_ message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: Strings.ok, style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: false, completion: nil)
  }
  
}
