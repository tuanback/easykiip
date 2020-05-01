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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var injectionContainer = AppDependencyContainer()
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    FirebaseApp.configure()
    // Use to change app language
    //AppSetting.languageCode = .en
    
    let launchVC = injectionContainer.makeLaunchVC()
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()
    window?.rootViewController = launchVC
    
    return true
  }
}

