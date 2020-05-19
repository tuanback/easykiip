//
//  Navigation.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

enum NavigationEvent {
  case push(vc: UIViewController)
  case present(vc: UIViewController)
  case dismiss
  case pop
}
