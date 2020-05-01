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

private var isMFAEnabled = false

public class LoginVC: NiblessViewController {
  
  private let viewModel: LoginViewModel
  
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
  }

  private func setupGoogleSignIn() {
    GIDSignIn.sharedInstance()?.presentingViewController = self
    GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    GIDSignIn.sharedInstance().delegate = self
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
    authenticateWithFirebase(credential: credential)
  }
  
  private func authenticateWithFirebase(credential: AuthCredential) {
    Auth.auth().signIn(with: credential) { (authResult, error) in
      if let error = error {
        let authError = error as NSError
        if (isMFAEnabled && authError.code == AuthErrorCode.secondFactorRequired.rawValue) {
          // The user is a multi-factor user. Second factor challenge is required.
          let resolver = authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
          var displayNameString = ""
          for tmpFactorInfo in (resolver.hints) {
            displayNameString += tmpFactorInfo.displayName ?? ""
            displayNameString += " "
          }
          self.showTextInputPrompt(withMessage: "Select factor to sign in\n\(displayNameString)", completionBlock: { userPressedOK, displayName in
            var selectedHint: PhoneMultiFactorInfo?
            for tmpFactorInfo in resolver.hints {
              if (displayName == tmpFactorInfo.displayName) {
                selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
              }
            }
            PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
              if error != nil {
                print("Multi factor start sign in failed. Error: \(error.debugDescription)")
              } else {
                self.showTextInputPrompt(withMessage: "Verification code for \(selectedHint?.displayName ?? "")", completionBlock: { userPressedOK, verificationCode in
                  let credential: PhoneAuthCredential? = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode!)
                  let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator.assertion(with: credential!)
                  resolver.resolveSignIn(with: assertion!) { authResult, error in
                    if error != nil {
                      print("Multi factor finanlize sign in failed. Error: \(error.debugDescription)")
                    } else {
                      self.navigationController?.popViewController(animated: true)
                    }
                  }
                })
              }
            }
          })
        } else {
          self.showMessagePrompt(error.localizedDescription)
          return
        }
        // ...
        return
      }
      // User is signed in
      // ...
    }
  }
  
  /*! @fn showTextInputPromptWithMessage
   @brief Shows a prompt with a text field and 'OK'/'Cancel' buttons.
   @param message The message to display.
   @param completion A block to call when the user taps 'OK' or 'Cancel'.
   */
  func showTextInputPrompt(withMessage message: String,
                           completionBlock: @escaping ((Bool, String?) -> Void)) {
    let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      completionBlock(false, nil)
    }
    weak var weakPrompt = prompt
    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
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
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: false, completion: nil)
  }
  
}
