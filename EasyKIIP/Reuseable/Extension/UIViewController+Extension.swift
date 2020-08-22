//
//  UIViewController+Extension.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/06/13.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  func hideNavBar() {
    navigationController?.isNavigationBarHidden = true
  }
  
  func showNavBar() {
    navigationController?.isNavigationBarHidden = false
  }
  
  func removeBackBarButtonTitle() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
  }
  
  func removeNavigaionBarBorder() {
    //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = false
  }
  
  func presentAlert(title: String?, message: String?, cancelActionText: String?, confirmActionText: String, completion: (() -> ())? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.view.tintColor = UIColor.appRed
    
    if let cancelTitle = cancelActionText {
      let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
      alert.addAction((cancelAction))
    }
    
    let alertAction = UIAlertAction(title: confirmActionText, style: .default, handler: { action in
      completion?()
    })
    
    alert.addAction(alertAction)
    
    present(alert, animated: true, completion: nil)
  }
}
