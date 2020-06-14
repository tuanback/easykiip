//
//  AppDelegate.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/19.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import EasyKIIPKit
import FBSDKLoginKit
import Firebase
import GoogleMobileAds
import GoogleSignIn
import KakaoOpenSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  lazy var injectionContainer = AppDependencyContainer()
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    InternetStateProvider.shared.startListen()
    configFirebaseAndGoogleSignIn()
    setupFacebookLogin(application: application, launchOptions: launchOptions)
    injectionContainer = AppDependencyContainer()
    let launchVC = injectionContainer.makeLaunchVC()
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()
    window?.rootViewController = launchVC
    
    return true
  }
  
  private func setupFacebookLogin(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance().handle(url) || KOSession.handleOpen(url) || ApplicationDelegate.shared.application(app, open: url, options: options)
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return GIDSignIn.sharedInstance().handle(url) || KOSession.handleOpen(url)
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    KOSession.handleDidEnterBackground()
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    KOSession.handleDidBecomeActive()
  }
  
  private func configFirebaseAndGoogleSignIn() {
    FirebaseApp.configure()
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    
    KOSession.shared()?.logoutAndClose(completionHandler: { (success, error) in
      if let err = error {
        print(err)
      }
      else {
        print("Logout succeeded")
      }
    })
    // Sign out for testing
    //    GIDSignIn.sharedInstance()?.signOut()
    //    try? Auth.auth().signOut()
  }
}

