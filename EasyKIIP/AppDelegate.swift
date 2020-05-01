//
//  AppDelegate.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/19.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import EasyKIIPKit
import EasyKIIP_iOS
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var injectionContainer = AppDependencyContainer()
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    configFirebaseAndGoogleSignIn()
    // Use to change app language
    AppSetting.languageCode = .vi
    
    let launchVC = injectionContainer.makeLaunchVC()
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()
    window?.rootViewController = launchVC
    
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance().handle(url)
  }
  
  private func configFirebaseAndGoogleSignIn() {
    FirebaseApp.configure()
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
  }
}

