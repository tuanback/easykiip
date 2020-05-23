//
//  Navigator.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/05/23.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

enum NavigationType {
  case push       // push view controller to navigation stack
  case present    // present view controller modally
}

protocol Navigator {
  associatedtype Destination
  
  func navigate(from viewController: UIViewController,
                to destination: Destination,
                type: NavigationType)
}
