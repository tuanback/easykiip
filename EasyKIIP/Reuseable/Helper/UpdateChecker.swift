//
//  UpdateChecker.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/07/18.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit

struct UpdateChecker {
  
  func showUpdatePopUp(target: UIViewController) {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy.MM.dd"
    let today = dateFormatter.string(from: date)
    
    if let skipDate = UserDefaults.standard.string(forKey: "skipUpdateToday") {
      if skipDate == today {
        return
      }
    }
    
    DispatchQueue.main.async {
      let updateAlert = UIAlertController(title: Strings.update,
                                          message: Strings.newVersionIsAvailableMsg,
                                          preferredStyle: .alert)
      updateAlert.view.tintColor = UIColor.appRed
      
      let updateAction = UIAlertAction(title: Strings.update, style: .default, handler: { (action) in
        // GOTO APPSTORE
        if let url = URL(string: "itms-apps://itunes.apple.com/us/app/easy-kiip/id1521739580") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
      })
      
      let laterAction = UIAlertAction(title: Strings.later, style: .default, handler: { (aciton) in
        // POSTPONE
        UserDefaults.standard.set(today, forKey: "skipUpdateToday")
      })
      updateAlert.addAction(laterAction)
      updateAlert.addAction(updateAction)
      target.present(updateAlert, animated: true, completion: nil)
    }
  }
  
  func isUpdateAvailable(completion: @escaping (Bool) -> Void) {
    guard let info = Bundle.main.infoDictionary,
      let currentVersion = info["CFBundleShortVersionString"] as? String,
      let identifier = info["CFBundleIdentifier"] as? String,
      let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
        completion(false)
        return
    }
    print(currentVersion)
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard let data  = data,
        let json      = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any],
        let result    = (json["results"] as? [Any])?.first as? [String: Any],
        let version   = result["version"] as? String else {
          completion(false)
          return
      }
      
      let isUpdateNeeded = self.isUpdateAvailable(currentVersion: currentVersion, onlineVersion: version)
      
      completion(isUpdateNeeded)
    }
    task.resume()
  }
  
  func isUpdateAvailable(currentVersion: String, onlineVersion: String) -> Bool {
    //MARK: Check if need to update the application
    let onlineVersionArray = onlineVersion.split(separator: ".")
    let currentVersionArray = currentVersion.split(separator: ".")
    
    var isUpdateNeeded = false
    
    if onlineVersionArray.count == currentVersionArray.count {
      for index in 0...onlineVersionArray.count - 1 {
        if onlineVersionArray[index] > currentVersionArray[index] {
          isUpdateNeeded = true
          break
        }
        
        if onlineVersionArray[index] < currentVersionArray[index] {
          break
        }
      }
    }
    else if onlineVersionArray.count > currentVersionArray.count {
      var isEqual = true
      
      for index in 0...currentVersionArray.count - 1 {
        if onlineVersionArray[index] > currentVersionArray[index] {
          isEqual = false
          isUpdateNeeded = true
          break
        }
        
        if onlineVersionArray[index] < currentVersionArray[index] {
          isEqual = false
          break
        }
      }
      
      if isEqual {
        isUpdateNeeded = true
      }
    }
    else {
      for index in 0...onlineVersionArray.count - 1 {
        if onlineVersionArray[index] > currentVersionArray[index] {
          isUpdateNeeded = true
          break
        }
        
        if onlineVersionArray[index] < currentVersionArray[index] {
          break
        }
      }
    }
    
    return isUpdateNeeded
  }
  
}
